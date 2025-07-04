import Foundation

enum AppConstants {
    // MARK: - API
    enum API {
        static let baseURL = "http://localhost:8000/api" // Cambiar por tu URL de producción
        static let timeout: TimeInterval = 30.0
    }
    
    // MARK: - Authentication
    enum Auth {
        static let tokenKey = "auth_token"
        static let minPasswordLength = 6
    }
    
    // MARK: - UI
    enum UI {
        static let animationDuration: Double = 0.3
        static let cornerRadius: CGFloat = 12.0
        static let defaultPadding: CGFloat = 20.0
    }
    
    // MARK: - Validation
    enum Validation {
        static let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    }
} 