import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToLogin = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    var onRegisterSuccess: ((String) -> Void)? = nil
    var onLoginTap: (() -> Void)? = nil
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: geometry.size.height * 0.04) {
                    VStack(spacing: geometry.size.height * 0.02) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: geometry.size.width * 0.18))
                            .foregroundColor(.accentColor)
                        Text("Crear Cuenta")
                            .font(.system(size: geometry.size.width * 0.09, weight: .bold))
                        Text("Regístrate para comenzar a usar TrainIA")
                            .font(.system(size: geometry.size.width * 0.045))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, geometry.size.height * 0.08)
                    
                    Spacer()
                    
                    VStack(spacing: geometry.size.height * 0.02) {
                        Group {
                            TextField("Nombre", text: $viewModel.name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                                .disableAutocorrection(true)
                            if !viewModel.name.trimmed.isNotEmpty {
                                Text("El nombre es obligatorio.")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            if let errors = viewModel.backendFieldErrors["name"] {
                                ForEach(errors, id: \.self) { error in
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
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
                            if let errors = viewModel.backendFieldErrors["email"] {
                                ForEach(errors, id: \.self) { error in
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            ZStack(alignment: .trailing) {
                                Group {
                                    if showPassword {
                                        TextField("Contraseña", text: $viewModel.password)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    } else {
                                        SecureField("Contraseña", text: $viewModel.password)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }
                                }
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                                .padding(.trailing, 8)
                                .accessibilityLabel(showPassword ? "Ocultar contraseña" : "Mostrar contraseña")
                            }
                            if !viewModel.password.isValidPassword(minLength: AppConstants.Auth.minPasswordLength) && !viewModel.password.isEmpty {
                                Text("La contraseña debe tener al menos \(AppConstants.Auth.minPasswordLength) caracteres.")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            if let errors = viewModel.backendFieldErrors["password"] {
                                ForEach(errors, id: \.self) { error in
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            ZStack(alignment: .trailing) {
                                Group {
                                    if showConfirmPassword {
                                        TextField("Confirmar contraseña", text: $viewModel.confirmPassword)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    } else {
                                        SecureField("Confirmar contraseña", text: $viewModel.confirmPassword)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }
                                }
                                Button(action: { showConfirmPassword.toggle() }) {
                                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                                .padding(.trailing, 8)
                                .accessibilityLabel(showConfirmPassword ? "Ocultar contraseña" : "Mostrar contraseña")
                            }
                            if !viewModel.confirmPassword.isEmpty && viewModel.password != viewModel.confirmPassword {
                                Text("Las contraseñas no coinciden.")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            if let errors = viewModel.backendFieldErrors["password_confirmation"] {
                                ForEach(errors, id: \.self) { error in
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, geometry.size.width * 0.08)
                    
                    if viewModel.showError {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal, geometry.size.width * 0.08)
                    }
                    
                    Button(action: {
                        Task {
                            await viewModel.register()
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(viewModel.isLoading ? "Registrando..." : "Crear Cuenta")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isFormValid && !viewModel.isLoading ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                    .padding(.horizontal, geometry.size.width * 0.08)
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Button(action: {
                            onLoginTap?()
                        }) {
                            Text("¿Ya tienes cuenta? Inicia sesión")
                                .font(.footnote)
                                .foregroundColor(.blue)
                                .underline()
                        }
                    }
                    .padding(.bottom, geometry.size.height * 0.04)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .navigationBarHidden(true)
                .alert(isPresented: $viewModel.showSuccess) {
                    Alert(
                        title: Text("¡Registro exitoso!"),
                        message: Text(viewModel.successMessage),
                        dismissButton: .default(Text("Ir a Iniciar Sesión")) {
                            onRegisterSuccess?(viewModel.email)
                            dismiss()
                        }
                    )
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .onAppear {
                viewModel.setAuthService(authService)
                viewModel.clearFields()
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthService())
} 