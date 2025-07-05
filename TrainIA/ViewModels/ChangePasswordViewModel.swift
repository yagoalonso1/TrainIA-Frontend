import Foundation
import SwiftUI

@MainActor
class ChangePasswordViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    
    @Published var showCurrentPassword = false
    @Published var showNewPassword = false
    @Published var showConfirmPassword = false
    
    @Published var errorCurrent = ""
    @Published var errorNew = ""
    @Published var errorConfirm = ""
    @Published var generalError = ""
    
    @Published var isLoading = false
    @Published var showSuccess = false
    
    @Published var passwordStrength: Int = 0
    @Published var passwordStrengthLabel = ""
    @Published var passwordStrengthColor: Color = .gray
    
    // MARK: - Private Properties
    private let authService: AuthService
    
    // MARK: - Initialization
    init(authService: AuthService? = nil) {
        self.authService = authService ?? AuthService.shared
    }
    
    // MARK: - Public Methods
    
    /// Validar formulario completo
    var isFormValid: Bool {
        return !currentPassword.isEmpty && 
               !newPassword.isEmpty && 
               newPassword.count >= 8 && 
               !confirmPassword.isEmpty && 
               newPassword == confirmPassword
    }
    
    /// Validar formulario y establecer errores
    func validateFormAndSetErrors() -> Bool {
        var isValid = true
        
        // Validar contraseña actual
        if currentPassword.isEmpty {
            DispatchQueue.main.async {
                self.errorCurrent = "La contraseña actual es requerida"
            }
            isValid = false
        } else {
            DispatchQueue.main.async {
                self.errorCurrent = ""
            }
        }
        
        // Validar nueva contraseña
        if newPassword.isEmpty {
            DispatchQueue.main.async {
                self.errorNew = "La nueva contraseña es requerida"
            }
            isValid = false
        } else if newPassword.count < 8 {
            DispatchQueue.main.async {
                self.errorNew = "La contraseña debe tener al menos 8 caracteres"
            }
            isValid = false
        } else {
            DispatchQueue.main.async {
                self.errorNew = ""
            }
        }
        
        // Validar confirmación
        if confirmPassword.isEmpty {
            DispatchQueue.main.async {
                self.errorConfirm = "Confirma tu nueva contraseña"
            }
            isValid = false
        } else if newPassword != confirmPassword {
            DispatchQueue.main.async {
                self.errorConfirm = "Las contraseñas no coinciden"
            }
            isValid = false
        } else {
            DispatchQueue.main.async {
                self.errorConfirm = ""
            }
        }
        
        return isValid
    }
    
    /// Validar campos individuales sin modificar errores
    func validateCurrentPassword() -> Bool {
        return !currentPassword.isEmpty
    }
    
    func validateNewPassword() -> Bool {
        return !newPassword.isEmpty && newPassword.count >= 8
    }
    
    func validateConfirmPassword() -> Bool {
        return !confirmPassword.isEmpty && newPassword == confirmPassword
    }
    
    /// Limpiar errores de forma segura
    func clearCurrentPasswordError() {
        DispatchQueue.main.async {
            self.errorCurrent = ""
        }
    }
    
    func clearNewPasswordError() {
        DispatchQueue.main.async {
            self.errorNew = ""
        }
    }
    
    func clearConfirmPasswordError() {
        DispatchQueue.main.async {
            self.errorConfirm = ""
        }
    }
    
    /// Calcular fortaleza de contraseña
    func calculatePasswordStrength() {
        guard !newPassword.isEmpty else {
            passwordStrength = 0
            passwordStrengthLabel = ""
            passwordStrengthColor = .gray
            return
        }
        
        var score = 0
        
        // Longitud
        score += min(newPassword.count * 4, 40)
        
        // Complejidad
        if newPassword.range(of: "[a-z]", options: .regularExpression) != nil { score += 10 }
        if newPassword.range(of: "[A-Z]", options: .regularExpression) != nil { score += 10 }
        if newPassword.range(of: "[0-9]", options: .regularExpression) != nil { score += 10 }
        if newPassword.range(of: "[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?]", options: .regularExpression) != nil { score += 10 }
        
        // Variedad de caracteres
        let uniqueChars = Set(newPassword).count
        score += min(uniqueChars * 2, 20)
        
        passwordStrength = min(score, 100)
        
        // Determinar etiqueta y color
        switch passwordStrength {
        case 80...100:
            passwordStrengthLabel = "Muy Fuerte"
            passwordStrengthColor = .green
        case 60..<80:
            passwordStrengthLabel = "Fuerte"
            passwordStrengthColor = .blue
        case 40..<60:
            passwordStrengthLabel = "Media"
            passwordStrengthColor = .orange
        case 20..<40:
            passwordStrengthLabel = "Débil"
            passwordStrengthColor = .red
        default:
            passwordStrengthLabel = "Muy Débil"
            passwordStrengthColor = .red
        }
    }
    
    /// Cambiar contraseña
    func changePassword() async {
        guard validateFormAndSetErrors() else { return }
        
        isLoading = true
        generalError = ""
        
        do {
            let response = try await authService.changePassword(
                currentPassword: currentPassword,
                newPassword: newPassword
            )
            
            if response.success {
                showSuccess = true
                resetForm()
                
                // Forzar logout automático después de 2 segundos
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    Task {
                        await self.authService.logout()
                    }
                }
            } else {
                generalError = response.message
            }
        } catch let error as BackendValidationError {
            // Manejar errores específicos del backend
            if let currentPasswordErrors = error.fieldErrors["current_password"] {
                errorCurrent = currentPasswordErrors.first ?? "Error en contraseña actual"
            }
            if let newPasswordErrors = error.fieldErrors["new_password"] {
                errorNew = newPasswordErrors.first ?? "Error en nueva contraseña"
            }
            generalError = error.message
        } catch {
            generalError = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Resetear formulario
    func resetForm() {
        currentPassword = ""
        newPassword = ""
        confirmPassword = ""
        errorCurrent = ""
        errorNew = ""
        errorConfirm = ""
        generalError = ""
        passwordStrength = 0
        passwordStrengthLabel = ""
        passwordStrengthColor = .gray
    }
    
    /// Limpiar errores
    func clearErrors() {
        errorCurrent = ""
        errorNew = ""
        errorConfirm = ""
        generalError = ""
    }
} 