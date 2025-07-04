import Foundation

enum AuthError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidCredentials
    case userNotFound
    case loginFailed(String)
    case networkError(String)
    case tokenExpired
    case unauthorizedAccess
    case validationError(String)
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .invalidResponse:
            return "Respuesta inválida del servidor"
        case .invalidCredentials:
            return "Credenciales incorrectas"
        case .userNotFound:
            return "Usuario no encontrado"
        case .loginFailed(let message):
            return message
        case .networkError(let message):
            return "Error de red: \(message)"
        case .tokenExpired:
            return "Tu sesión ha expirado. Por favor inicia sesión nuevamente"
        case .unauthorizedAccess:
            return "Acceso no autorizado"
        case .validationError(let message):
            return "Error de validación: \(message)"
        case .serverError(let code):
            return "Error del servidor (código: \(code))"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .invalidURL:
            return "La URL configurada no es válida"
        case .invalidResponse:
            return "El servidor no respondió correctamente"
        case .invalidCredentials:
            return "Email o contraseña incorrectos"
        case .userNotFound:
            return "No existe un usuario con este email"
        case .loginFailed:
            return "No se pudo completar el proceso de login"
        case .networkError:
            return "Problema de conectividad"
        case .tokenExpired:
            return "El token de autenticación ha expirado"
        case .unauthorizedAccess:
            return "Sin permisos suficientes"
        case .validationError:
            return "Los datos proporcionados no son válidos"
        case .serverError:
            return "Error interno del servidor"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidURL:
            return "Contacta al administrador para verificar la configuración"
        case .invalidResponse:
            return "Intenta nuevamente en unos momentos"
        case .invalidCredentials:
            return "Verifica tu email y contraseña"
        case .userNotFound:
            return "Registra una cuenta nueva si no la tienes"
        case .loginFailed:
            return "Verifica tus credenciales e intenta nuevamente"
        case .networkError:
            return "Verifica tu conexión a internet"
        case .tokenExpired:
            return "Inicia sesión nuevamente"
        case .unauthorizedAccess:
            return "Contacta al administrador"
        case .validationError:
            return "Revisa la información ingresada"
        case .serverError:
            return "Intenta nuevamente más tarde"
        }
    }
} 