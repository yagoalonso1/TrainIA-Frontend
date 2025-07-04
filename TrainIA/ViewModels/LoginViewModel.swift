import Foundation
import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    
    // MARK: - Dependencies
    var authService: AuthService?
    
    // MARK: - Initialization
    init() {
        // AuthService se establecerá desde la vista
    }
    
    // MARK: - Setup
    func setAuthService(_ authService: AuthService) {
        self.authService = authService
    }
    
    // MARK: - Computed Properties
    
    /// Validar si el formulario es válido
    var isFormValid: Bool {
        email.trimmed.isValidEmail && 
        password.isValidPassword(minLength: AppConstants.Auth.minPasswordLength) &&
        !isLoading
    }
    
    // MARK: - Public Methods
    
    /// Realizar login
    func login() async {
        guard let authService = authService else {
            showError(message: "Error de configuración")
            return
        }
        
        guard isFormValid else {
            showError(message: "Por favor, completa todos los campos correctamente")
            return
        }
        
        setLoadingState(true)
        clearError()
        
        do {
            let _ = try await authService.login(email: email.trimmed, password: password)
            // Login exitoso - la navegación se maneja en la vista
        } catch {
            handleLoginError(error)
        }
        
        setLoadingState(false)
    }
    
    /// Limpiar todos los campos
    func clearFields() {
        email = ""
        password = ""
        clearError()
    }
    
    /// Limpiar error actual
    func clearError() {
        errorMessage = ""
        showError = false
    }
    
    // MARK: - Private Methods
    
    private func setLoadingState(_ loading: Bool) {
        isLoading = loading
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    private func handleLoginError(_ error: Error) {
        if let authError = error as? AuthError {
            switch authError {
            case .invalidCredentials:
                showError(message: "Email o contraseña incorrectos")
            case .networkError(_):
                showError(message: "Error de conexión. Verifica tu internet")
            case .validationError(let message):
                showError(message: message)
            default:
                showError(message: authError.localizedDescription)
            }
        } else {
            showError(message: "Error inesperado. Intenta nuevamente")
        }
    }
} 