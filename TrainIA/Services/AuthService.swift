import Foundation

@MainActor
class AuthService: ObservableObject {
    // MARK: - Published Properties
    @Published var currentUser: User?
    @Published var isLoggedIn = false
    
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
    
    // MARK: - Public Methods
    
    /// Verificar si el usuario está autenticado
    func checkAuthStatus() {
        if let token = getStoredToken(), !token.isEmpty {
            // Aquí podrías hacer una llamada para verificar si el token es válido
            isLoggedIn = true
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