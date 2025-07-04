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
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.loginFailed("Email y contraseña son requeridos")
        }
        
        guard let url = URL(string: "\(baseURL)\(Constants.loginEndpoint)") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(Constants.contentType, forHTTPHeaderField: "Content-Type")
        
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
                throw AuthError.loginFailed("Credenciales incorrectas")
                
            case 422:
                if let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw AuthError.loginFailed(errorData.message)
                } else {
                    throw AuthError.loginFailed("Error de validación")
                }
                
            default:
                if let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw AuthError.loginFailed(errorData.message)
                } else {
                    throw AuthError.loginFailed("Error del servidor")
                }
            }
            
        } catch let error as AuthError {
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