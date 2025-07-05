import SwiftUI

struct DeleteAccountView: View {
    @StateObject private var viewModel = DeleteAccountViewModel()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.red)
                        
                        Text("Eliminar Cuenta")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Esta acción es irreversible")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 36)
                    
                    // Advertencia
                    if let warningData = viewModel.warningData {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(warningData.warning)
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(warningData.items, id: \.self) { item in
                                    HStack(spacing: 8) {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                        Text(item)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                            
                            Text(warningData.note)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                    }
                    
                    // Formulario
                    VStack(spacing: 20) {
                        // Campo de contraseña
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Contraseña")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                if viewModel.showPassword {
                                    TextField("Ingresa tu contraseña", text: $viewModel.password)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .onChange(of: viewModel.password) { oldValue, newValue in
                                            viewModel.clearPasswordError()
                                        }
                                } else {
                                    SecureField("Ingresa tu contraseña", text: $viewModel.password)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .onChange(of: viewModel.password) { oldValue, newValue in
                                            viewModel.clearPasswordError()
                                        }
                                }
                                
                                Button(action: {
                                    viewModel.showPassword.toggle()
                                }) {
                                    Image(systemName: viewModel.showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if !viewModel.errorPassword.isEmpty {
                                Text(viewModel.errorPassword)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Confirmación
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Toggle("", isOn: $viewModel.confirmDeletion)
                                    .onChange(of: viewModel.confirmDeletion) { oldValue, newValue in
                                        viewModel.clearConfirmError()
                                    }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Confirmo que quiero eliminar mi cuenta")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Text("Esta acción no se puede deshacer")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if !viewModel.errorConfirm.isEmpty {
                                Text(viewModel.errorConfirm)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Error general
                    if !viewModel.generalError.isEmpty {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.red)
                            Text(viewModel.generalError)
                                .font(.caption)
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                    }
                    
                    // Botón de eliminación
                    Button(action: {
                        Task {
                            await viewModel.deleteAccount()
                            dismiss()
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "trash")
                                    .font(.headline)
                            }
                            Text(viewModel.isLoading ? "Eliminando..." : "Eliminar Cuenta")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(viewModel.isFormValid ? Color.red : Color.gray)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                    
                    // Botón de cancelar
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancelar")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                    }
                    .disabled(viewModel.isLoading)
                    
                    Spacer(minLength: 24)
                }
            }
            .navigationTitle("Eliminar Cuenta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .onAppear {
                Task {
                    await viewModel.loadDeletionWarning()
                }
            }
            .alert("Cuenta eliminada exitosamente", isPresented: $viewModel.showDeletionAlert) {
                Button("Aceptar") {
                    authService.logout()
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    DeleteAccountView()
        .environmentObject(AuthService())
} 