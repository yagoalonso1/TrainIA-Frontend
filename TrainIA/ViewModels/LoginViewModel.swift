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
    @Published var backendFieldErrors: [String: [String]] = [:]
    
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
            showError(message: "Completa todos los campos correctamente")
            return
        }
        
        isLoading = true
        clearError()
        backendFieldErrors = [:]
        
        do {
            let _ = try await authService.login(email: email, password: password)
            // Tras login exitoso, refrescar perfil actualizado
            do {
                let user = try await authService.getProfile()
                authService.currentUser = user
            } catch {
                // Si falla, al menos sigue con el usuario del login
            }
        } catch let error as BackendValidationError {
            backendFieldErrors = error.fieldErrors
            showError(message: error.message)
        } catch {
            handleLoginError(error)
        }
        
        isLoading = false
    }
    
    /// Limpiar todos los campos
    func clearFields() {
        email = ""
        password = ""
        clearError()
        backendFieldErrors = [:]
    }
    
    /// Limpiar error actual
    func clearError() {
        errorMessage = ""
        showError = false
    }
    
    // MARK: - Private Methods
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    private func handleLoginError(_ error: Error) {
        if let authError = error as? AuthError {
            showError(message: authError.localizedDescription)
        } else {
            showError(message: "Error inesperado. Intenta nuevamente")
        }
    }
} 