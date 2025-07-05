import Foundation
import SwiftUI

@MainActor
class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var showSuccess = false
    @Published var successMessage = ""
    
    var authService: AuthService?
    
    func setAuthService(_ authService: AuthService) {
        self.authService = authService
    }
    
    var isFormValid: Bool {
        email.trimmed.isValidEmail && !isLoading
    }
    
    func sendForgotPassword() async {
        guard let authService = authService else {
            showError(message: "Error de configuración")
            return
        }
        guard isFormValid else {
            showError(message: "Introduce un email válido")
            return
        }
        isLoading = true
        clearError()
        do {
            let message = try await authService.forgotPassword(email: email.trimmed)
            showSuccess = true
            successMessage = message
        } catch {
            showError(message: error.localizedDescription)
        }
        isLoading = false
    }
    
    func clearError() {
        errorMessage = ""
        showError = false
    }
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
} 