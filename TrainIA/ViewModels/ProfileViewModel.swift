import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var backendFieldErrors: [String: [String]] = [:]
    @Published var avatarImage: UIImage?
    @Published var isUpdating = false
    @Published var showSuccess = false
    @Published var successMessage = ""
    
    var authService: AuthService?
    
    func setAuthService(_ authService: AuthService) {
        self.authService = authService
    }
    
    func fetchProfile() async {
        guard let authService = authService else { return }
        isLoading = true
        showError = false
        errorMessage = ""
        do {
            let user = try await authService.getProfile()
            self.user = user
        } catch {
            self.user = nil
            errorMessage = "No se pudo cargar el perfil"
            showError = true
        }
        isLoading = false
    }
    
    func updateProfile(name: String?, email: String?, avatar: UIImage?) async {
        guard let authService = authService else { return }
        isUpdating = true
        showError = false
        errorMessage = ""
        backendFieldErrors = [:]
        do {
            let avatarData = avatar?.jpegData(compressionQuality: 0.8)
            let user = try await authService.updateProfile(name: name, email: email, avatar: avatarData)
            self.user = user
            authService.currentUser = user
            showSuccess = true
            successMessage = "Perfil actualizado correctamente"
        } catch let error as BackendValidationError {
            backendFieldErrors = error.fieldErrors
            errorMessage = error.message
            showError = true
        } catch {
            errorMessage = "No se pudo actualizar el perfil"
            showError = true
        }
        isUpdating = false
    }
    
    func clearBackendErrors() {
        backendFieldErrors = [:]
        errorMessage = ""
        showError = false
    }
} 