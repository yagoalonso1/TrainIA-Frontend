import Foundation

@MainActor
class AuthService: ObservableObject {
    // MARK: - Shared Instance
    static let shared = AuthService()
    
    // MARK: - Published Properties
    @Published var currentUser: User?
    @Published var isLoggedIn = false
    @Published var isCheckingAuth = true
    
    // MARK: - Private Properties
    private let baseURL: String
    private let userDefaults: UserDefaults
    private let urlSession: URLSession
    
    // MARK: - Constants
    private enum Constants {
        static let loginEndpoint = "/login"
        static let contentType = "application/json"
    }
    
    // MARK: - Initialization
    init(
        baseURL: String = AppConstants.API.baseURL,
        userDefaults: UserDefaults = .standard,
        urlSession: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.userDefaults = userDefaults
        self.urlSession = urlSession
        
        checkAuthStatus()
    }
    
    // MARK: - Private Initializer for Singleton
    private init() {
        self.baseURL = AppConstants.API.baseURL
        self.userDefaults = .standard
        self.urlSession = .shared
        
        checkAuthStatus()
    }
    
    // MARK: - Public Methods
    
    /// Verificar si el usuario está autenticado
    func checkAuthStatus() {
        isCheckingAuth = true
        if let token = getStoredToken(), !token.isEmpty {
            Task {
                do {
                    let user = try await getProfile()
                    self.currentUser = user
                    self.isLoggedIn = true
                } catch {
                    // Token inválido o expirado
                    self.logout()
                }
                self.isCheckingAuth = false
            }
        } else {
            self.logout()
            self.isCheckingAuth = false
        }
    }
    
    /// Login de usuario
    func login(email: String, password: String) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/login") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginRequest = LoginRequest(email: email, password: password)
        
        do {
            let jsonData = try JSONEncoder().encode(loginRequest)
            request.httpBody = jsonData
            
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                
                // Guardar token y usuario
                saveToken(loginResponse.data.token)
                currentUser = loginResponse.data.user
                isLoggedIn = true
                
                return loginResponse
            case 401:
                // Credenciales incorrectas
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let message = json?["message"] as? String ?? "Credenciales incorrectas"
                let errors = json?["errors"] as? [String: [String]] ?? ["email": [message]]
                throw BackendValidationError(message: message, fieldErrors: errors)
            case 422:
                // Errores de validación
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let message = json?["message"] as? String ?? "Errores de validación"
                let errors = json?["errors"] as? [String: [String]] ?? [:]
                throw BackendValidationError(message: message, fieldErrors: errors)
            default:
                if let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw AuthError.loginFailed(errorData.message)
                } else {
                    throw AuthError.loginFailed("Error del servidor")
                }
            }
        } catch let error as BackendValidationError {
            throw error
        } catch {
            throw AuthError.networkError(error.localizedDescription)
        }
    }
    
    /// Logout de usuario
    func logout() {
        removeToken()
        currentUser = nil
        isLoggedIn = false
    }
    
    /// Obtener token para requests autenticados
    func getAuthToken() -> String? {
        return getStoredToken()
    }
    
    /// Registro de usuario
    func register(name: String, email: String, password: String, passwordConfirmation: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/register") else {
            throw AuthError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = [
            "name": name,
            "email": email,
            "password": password,
            "password_confirmation": passwordConfirmation
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        do {
            let (data, response) = try await urlSession.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            if httpResponse.statusCode == 201 {
                // Registro exitoso, decodificar mensaje
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let message = json?["message"] as? String ?? "Registro exitoso"
                return message
            } else if httpResponse.statusCode == 422 {
                // Errores de validación
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let message = json?["message"] as? String ?? "Errores de validación"
                let errors = json?["errors"] as? [String: [String]] ?? [:]
                throw BackendValidationError(message: message, fieldErrors: errors)
            } else if let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw AuthError.loginFailed(errorData.message)
            } else {
                throw AuthError.loginFailed("Error desconocido")
            }
        } catch let error as BackendValidationError {
            throw error
        } catch {
            throw AuthError.networkError(error.localizedDescription)
        }
    }
    
    /// Obtener perfil de usuario autenticado
    func getProfile() async throws -> User {
        guard let url = URL(string: "\(baseURL)/user") else {
            throw AuthError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AuthError.invalidResponse
        }
        let user = try JSONDecoder().decode(User.self, from: data)
        return user
    }

    /// Actualizar perfil de usuario (nombre, email, avatar)
    func updateProfile(name: String?, email: String?, avatar: Data?) async throws -> User {
        guard let url = URL(string: "\(baseURL)/profile/update") else {
            throw AuthError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let token = getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        if let name = name {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(name)\r\n".data(using: .utf8)!)
        }
        if let email = email {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"email\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(email)\r\n".data(using: .utf8)!)
        }
        if let avatar = avatar {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"avatar\"; filename=\"avatar.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(avatar)
            body.append("\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }
        if httpResponse.statusCode == 200 {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            if let dataDict = json?["data"] as? [String: Any],
               let userDict = dataDict["user"] {
                let userData = try JSONSerialization.data(withJSONObject: userDict)
                let user = try JSONDecoder().decode(User.self, from: userData)
                return user
            }
            throw AuthError.invalidResponse
        } else if httpResponse.statusCode == 422 {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let message = json?["message"] as? String ?? "Errores de validación"
            let errors = json?["errors"] as? [String: [String]] ?? [:]
            throw BackendValidationError(message: message, fieldErrors: errors)
        } else if let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            throw AuthError.loginFailed(errorData.message)
        } else {
            throw AuthError.loginFailed("Error desconocido")
        }
    }
    
    /// Solicitar recuperación de contraseña
    func forgotPassword(email: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/forgot-password") else {
            throw AuthError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["email": email]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let message = json?["message"] as? String ?? ""
        if httpResponse.statusCode == 200 {
            return message
        } else {
            throw AuthError.loginFailed(message.isEmpty ? "Error al solicitar recuperación" : message)
        }
    }
    
    /// Cambiar contraseña de usuario autenticado
    func changePassword(currentPassword: String, newPassword: String) async throws -> ChangePasswordResponse {
        guard let url = URL(string: "\(baseURL)/change-password") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let changePasswordRequest = ChangePasswordRequest(
            current_password: currentPassword,
            new_password: newPassword
        )
        
        do {
            let jsonData = try JSONEncoder().encode(changePasswordRequest)
            request.httpBody = jsonData
            
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                let changePasswordResponse = try JSONDecoder().decode(ChangePasswordResponse.self, from: data)
                return changePasswordResponse
            case 422:
                // Errores de validación (fortaleza de contraseña, contraseña actual incorrecta, etc.)
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let message = json?["message"] as? String ?? "Errores de validación"
                let errors = json?["errors"] as? [String: [String]] ?? [:]
                throw BackendValidationError(message: message, fieldErrors: errors)
            case 401:
                // Token expirado o inválido
                throw AuthError.loginFailed("Sesión expirada. Por favor, inicia sesión nuevamente.")
            default:
                if let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw AuthError.loginFailed(errorData.message)
                } else {
                    throw AuthError.loginFailed("Error del servidor")
                }
            }
        } catch let error as BackendValidationError {
            throw error
        } catch {
            throw AuthError.networkError(error.localizedDescription)
        }
    }
    
    /// Obtener advertencia de eliminación de cuenta
    func getDeletionWarning() async throws -> DeletionWarningResponse {
        guard let url = URL(string: "\(baseURL)/account/deletion-warning") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            return try JSONDecoder().decode(DeletionWarningResponse.self, from: data)
        } else {
            if let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw AuthError.loginFailed(errorData.message)
            } else {
                throw AuthError.loginFailed("Error al obtener información de eliminación")
            }
        }
    }
    
    /// Eliminar cuenta
    func deleteAccount(password: String, confirmDeletion: Bool) async throws -> DeleteAccountResponse {
        guard let url = URL(string: "\(baseURL)/account") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let deleteRequest = DeleteAccountRequest(
            password: password,
            confirm_deletion: confirmDeletion
        )
        
        do {
            let jsonData = try JSONEncoder().encode(deleteRequest)
            request.httpBody = jsonData
            
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                let deleteResponse = try JSONDecoder().decode(DeleteAccountResponse.self, from: data)
                return deleteResponse
            case 422:
                // Errores de validación (contraseña incorrecta, confirmación requerida, etc.)
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let message = json?["message"] as? String ?? "Errores de validación"
                let errors = json?["errors"] as? [String: [String]] ?? [:]
                throw BackendValidationError(message: message, fieldErrors: errors)
            case 401:
                // Token expirado o inválido
                throw AuthError.loginFailed("Sesión expirada. Por favor, inicia sesión nuevamente.")
            default:
                if let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw AuthError.loginFailed(errorData.message)
                } else {
                    throw AuthError.loginFailed("Error al eliminar la cuenta")
                }
            }
        } catch let error as BackendValidationError {
            throw error
        } catch {
            throw AuthError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Private Methods
    
    private func saveToken(_ token: String) {
        userDefaults.set(token, forKey: AppConstants.Auth.tokenKey)
    }
    
    private func getStoredToken() -> String? {
        return userDefaults.string(forKey: AppConstants.Auth.tokenKey)
    }
    
    private func removeToken() {
        userDefaults.removeObject(forKey: AppConstants.Auth.tokenKey)
    }
} 