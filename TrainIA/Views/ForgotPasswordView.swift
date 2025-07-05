import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = ForgotPasswordViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 48))
                        .foregroundColor(.accentColor)
                    Text("¿Olvidaste tu contraseña?")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Introduce tu email y te enviaremos instrucciones para restablecer tu contraseña.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                VStack(spacing: 16) {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    if !viewModel.email.trimmed.isValidEmail && !viewModel.email.isEmpty {
                        Text("Introduce un email válido.")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 40)
                
                if viewModel.showError {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal, 40)
                }
                
                Button(action: {
                    Task { await viewModel.sendForgotPassword() }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text(viewModel.isLoading ? "Enviando..." : "Enviar instrucciones")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isFormValid && !viewModel.isLoading ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!viewModel.isFormValid || viewModel.isLoading)
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .navigationTitle("Recuperar contraseña")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
            .onAppear {
                viewModel.setAuthService(authService)
                viewModel.clearError()
            }
            .alert(isPresented: $viewModel.showSuccess) {
                Alert(
                    title: Text("¡Listo!"),
                    message: Text(viewModel.successMessage),
                    dismissButton: .default(Text("Cerrar")) { dismiss() }
                )
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
        .environmentObject(AuthService())
} 