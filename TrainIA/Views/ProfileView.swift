import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showEdit = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if let user = viewModel.user {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 124, height: 124)
                                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                                AsyncImage(url: URL(string: user.avatarUrl)) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    ZStack {
                                        Circle().fill(Color(.systemGray5))
                                        Text(user.name.prefix(2).uppercased())
                                            .font(.system(size: 44, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(width: 110, height: 110)
                                .clipShape(Circle())
                            }
                            Text(user.name)
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.primary)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            HStack(spacing: 6) {
                                Image(systemName: user.subscriptionStatus == "premium" ? "star.fill" : "person.fill")
                                    .font(.caption)
                                    .foregroundColor(user.subscriptionStatus == "premium" ? .yellow : .blue)
                                Text(user.subscriptionStatus.capitalized)
                                    .font(.caption)
                                    .foregroundColor(user.subscriptionStatus == "premium" ? .yellow : .blue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.top, 36)
                        
                        VStack(spacing: 0) {
                            Text("INFORMACIÓN")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                            VStack(spacing: 0) {
                                ProfileInfoRow(label: "Nombre", value: user.name)
                                Divider().padding(.leading, 20)
                                ProfileInfoRow(label: "Email", value: user.email)
                                Divider().padding(.leading, 20)
                                ProfileInfoRow(label: "Suscripción", value: user.subscriptionStatus.capitalized, color: user.subscriptionStatus == "premium" ? .yellow : .blue)
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
                            .padding(.horizontal, 12)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                    } else if viewModel.isLoading {
                        ProgressView("Cargando perfil...")
                            .padding(.top, 80)
                    } else if viewModel.showError {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, 80)
                    }
                    Spacer(minLength: 24)
                }
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.user != nil {
                        Button(action: { showEdit = true }) {
                            Image(systemName: "pencil")
                        }
                        .accessibilityLabel("Editar perfil")
                    }
                }
            }
            .sheet(isPresented: $showEdit, onDismiss: {
                Task { await viewModel.fetchProfile() }
            }) {
                if let user = viewModel.user {
                    EditProfileView(user: user, viewModel: viewModel)
                        .environmentObject(authService)
                }
            }
            .onAppear {
                viewModel.setAuthService(authService)
                Task { await viewModel.fetchProfile() }
            }
        }
    }
}

struct ProfileInfoRow: View {
    let label: String
    let value: String
    var color: Color? = nil
    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(color ?? .secondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthService())
} 