import Foundation
import SwiftUI

@MainActor
class RegisterViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var showSuccess = false
    @Published var successMessage = ""
    @Published var backendFieldErrors: [String: [String]] = [:]
    
    var authService: AuthService?
    
    func setAuthService(_ authService: AuthService) {
        self.authService = authService
    }
    
    var isFormValid: Bool {
        name.trimmed.isNotEmpty &&
        email.trimmed.isValidEmail &&
        password.isValidPassword(minLength: AppConstants.Auth.minPasswordLength) &&
        password == confirmPassword &&
        !isLoading
    }
    
    func register() async {
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
            let message = try await authService.register(name: name.trimmed, email: email.trimmed, password: password, passwordConfirmation: confirmPassword)
            showSuccess = true
            successMessage = message
        } catch let error as BackendValidationError {
            backendFieldErrors = error.fieldErrors
            showError(message: error.message)
        } catch {
            handleRegisterError(error)
        }
        isLoading = false
    }
    
    func clearFields() {
        name = ""
        email = ""
        password = ""
        confirmPassword = ""
        clearError()
        backendFieldErrors = [:]
    }
    func clearError() {
        errorMessage = ""
        showError = false
    }
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    private func handleRegisterError(_ error: Error) {
        if let authError = error as? AuthError {
            showError(message: authError.localizedDescription)
        } else {
            showError(message: "Error inesperado. Intenta nuevamente")
        }
    }
} 