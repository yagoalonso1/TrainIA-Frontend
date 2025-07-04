import SwiftUI
import PhotosUI

struct EditProfileView: View {
    let user: User
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authService: AuthService
    @State private var name: String
    @State private var email: String
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var inputImage: UIImage? = nil
    @State private var showAlert = false
    
    init(user: User, viewModel: ProfileViewModel) {
        self.user = user
        self.viewModel = viewModel
        _name = State(initialValue: user.name)
        _email = State(initialValue: user.email)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Avatar")) {
                    HStack {
                        Spacer()
                        ZStack(alignment: .bottomTrailing) {
                            if let image = viewModel.avatarImage ?? inputImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            } else {
                                AsyncImage(url: URL(string: user.avatarUrl)) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .foregroundColor(.accentColor)
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                            }
                            Menu {
                                Button("Elegir de la galería", systemImage: "photo") { showImagePicker = true }
                                Button("Tomar foto", systemImage: "camera") { showCamera = true }
                            } label: {
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                                    .padding(8)
                                    .background(Color(.systemBackground))
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                        }
                        Spacer()
                    }
                }
                Section(header: Text("Información")) {
                    TextField("Nombre", text: $name)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                    if let errors = viewModel.backendFieldErrors["name"] {
                        ForEach(errors, id: \.self) { error in
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    if let errors = viewModel.backendFieldErrors["email"] {
                        ForEach(errors, id: \.self) { error in
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                if viewModel.showError {
                    Section {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Editar perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.updateProfile(name: name, email: email, avatar: inputImage ?? viewModel.avatarImage)
                            if viewModel.showSuccess {
                                dismiss()
                            }
                        }
                    }) {
                        if viewModel.isUpdating {
                            ProgressView()
                        } else {
                            Text("Guardar")
                        }
                    }
                    .disabled(viewModel.isUpdating)
                }
            }
            .photosPicker(isPresented: $showImagePicker, selection: $selectedPhoto, matching: .images)
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $inputImage)
            }
            .onChange(of: selectedPhoto) { newItem in
                if let newItem {
                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                            inputImage = uiImage
                        }
                    }
                }
            }
        }
    }
}

// ImagePicker para cámara
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

#Preview {
    EditProfileView(user: User(id: 1, name: "Nombre", email: "email@demo.com", avatarUrl: "", role: "user", subscriptionStatus: "free"), viewModel: ProfileViewModel())
        .environmentObject(AuthService())
} 