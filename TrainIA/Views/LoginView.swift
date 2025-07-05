import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToRegister = false
    @State private var navigateToHome = false
    @State private var showPassword = false
    @State private var showForgotPassword = false
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: geometry.size.height * 0.04) {
                    // Header
                    VStack(spacing: geometry.size.height * 0.02) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: geometry.size.width * 0.18))
                            .foregroundColor(.accentColor)
                        Text("Iniciar Sesión")
                            .font(.system(size: geometry.size.width * 0.09, weight: .bold))
                        Text("Ingresa tus credenciales para acceder")
                            .font(.system(size: geometry.size.width * 0.045))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, geometry.size.height * 0.08)
                    
                    Spacer()
                    
                    // Formulario
                    VStack(spacing: geometry.size.height * 0.02) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.headline)
                                .foregroundColor(.primary)
                            TextField("Ingresa tu email", text: $viewModel.email)
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
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Contraseña")
                                .font(.headline)
                                .foregroundColor(.primary)
                            ZStack(alignment: .trailing) {
                                Group {
                                    if showPassword {
                                        TextField("Ingresa tu contraseña", text: $viewModel.password)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    } else {
                                        SecureField("Ingresa tu contraseña", text: $viewModel.password)
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
                            await viewModel.login()
                            if authService.isLoggedIn {
                                navigateToHome = true
                            }
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(viewModel.isLoading ? "Iniciando sesión..." : "Iniciar Sesión")
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
                            navigateToRegister = true
                        }) {
                            Text("¿No tienes cuenta? Crear cuenta")
                                .font(.footnote)
                                .foregroundColor(.blue)
                                .underline()
                        }
                    }
                    .padding(.bottom, geometry.size.height * 0.04)
                    
                    // Botón de forgot password
                    Button(action: { showForgotPassword = true }) {
                        Text("¿Olvidaste tu contraseña?")
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .underline()
                    }
                    .padding(.top, 4)
                    .sheet(isPresented: $showForgotPassword) {
                        ForgotPasswordView()
                            .environmentObject(authService)
                    }
                    
                    NavigationLink(destination: HomeView().environmentObject(authService), isActive: $navigateToHome) { EmptyView() }
                    NavigationLink(destination: RegisterView().navigationBarBackButtonHidden(true), isActive: $navigateToRegister) { EmptyView() }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .navigationBarHidden(true)
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
    LoginView()
        .environmentObject(AuthService())
} 