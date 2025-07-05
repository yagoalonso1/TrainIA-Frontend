import Foundation
import SwiftUI

@MainActor
class DeleteAccountViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var password = ""
    @Published var confirmDeletion = false
    @Published var showPassword = false
    
    @Published var errorPassword = ""
    @Published var errorConfirm = ""
    @Published var generalError = ""
    
    @Published var isLoading = false
    @Published var showSuccess = false
    @Published var showWarning = false
    
    @Published var warningData: DeletionWarningData?
    
    @Published var showDeletionAlert = false
    
    // MARK: - Private Properties
    private let authService: AuthService
    
    // MARK: - Computed Properties
    var isFormValid: Bool {
        !password.isEmpty && confirmDeletion
    }
    
    // MARK: - Initialization
    init(authService: AuthService? = nil) {
        self.authService = authService ?? AuthService.shared
    }
    
    // MARK: - Public Methods
    
    /// Cargar advertencia de eliminación
    func loadDeletionWarning() async {
        isLoading = true
        generalError = ""
        
        do {
            let response = try await authService.getDeletionWarning()
            if response.success {
                warningData = response.data
                showWarning = true
            } else {
                generalError = "Error al cargar la información de eliminación"
            }
        } catch {
            generalError = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Eliminar cuenta
    func deleteAccount() async {
        guard validateFormAndSetErrors() else { return }
        
        isLoading = true
        generalError = ""
        
        do {
            let response = try await authService.deleteAccount(
                password: password,
                confirmDeletion: confirmDeletion
            )
            
            if response.success {
                resetForm()
                await authService.logout() // Logout inmediato tras eliminar cuenta
            } else {
                generalError = response.message
            }
        } catch let error as BackendValidationError {
            // Manejar errores específicos del backend
            if let passwordErrors = error.fieldErrors["password"] {
                errorPassword = passwordErrors.first ?? "Error en contraseña"
            }
            if let confirmErrors = error.fieldErrors["confirm_deletion"] {
                errorConfirm = confirmErrors.first ?? "Error en confirmación"
            }
            generalError = error.message
        } catch {
            generalError = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Validar formulario y establecer errores
    func validateFormAndSetErrors() -> Bool {
        var isValid = true
        
        // Validar contraseña
        if password.isEmpty {
            DispatchQueue.main.async {
                self.errorPassword = "La contraseña es requerida"
            }
            isValid = false
        } else {
            DispatchQueue.main.async {
                self.errorPassword = ""
            }
        }
        
        // Validar confirmación
        if !confirmDeletion {
            DispatchQueue.main.async {
                self.errorConfirm = "Debes confirmar la eliminación"
            }
            isValid = false
        } else {
            DispatchQueue.main.async {
                self.errorConfirm = ""
            }
        }
        
        return isValid
    }
    
    /// Limpiar errores
    func clearErrors() {
        DispatchQueue.main.async {
            self.errorPassword = ""
            self.errorConfirm = ""
            self.generalError = ""
        }
    }
    
    /// Limpiar error de contraseña
    func clearPasswordError() {
        DispatchQueue.main.async {
            if !self.password.isEmpty {
                self.errorPassword = ""
            }
        }
    }
    
    /// Limpiar error de confirmación
    func clearConfirmError() {
        DispatchQueue.main.async {
            if self.confirmDeletion {
                self.errorConfirm = ""
            }
        }
    }
    
    /// Resetear formulario
    func resetForm() {
        password = ""
        confirmDeletion = false
        showPassword = false
        clearErrors()
    }
} 