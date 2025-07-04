import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToHome = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    
                    Text("Iniciar Sesión")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Ingresa tus credenciales para acceder")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Formulario
                VStack(spacing: 20) {
                    // Campo Email
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Ingresa tu email", text: $viewModel.email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    // Campo Contraseña
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Contraseña")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        SecureField("Ingresa tu contraseña", text: $viewModel.password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding(.horizontal, 40)
                
                // Mensaje de error
                if viewModel.showError {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal, 40)
                }
                
                // Botón de Login
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
                    .background(
                        viewModel.isFormValid && !viewModel.isLoading 
                            ? Color.blue 
                            : Color.gray.opacity(0.3)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!viewModel.isFormValid || viewModel.isLoading)
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Navegación a Home
                NavigationLink(
                    destination: HomeView()
                        .environmentObject(authService),
                    isActive: $navigateToHome
                ) {
                    EmptyView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            viewModel.setAuthService(authService)
            viewModel.clearFields()
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthService())
} 