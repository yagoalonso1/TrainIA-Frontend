import Foundation

extension String {
    /// Validar si el string es un email válido
    var isValidEmail: Bool {
        guard !isEmpty else { return false }
        
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", AppConstants.Validation.emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    /// Validar si el string es una contraseña válida
    func isValidPassword(minLength: Int = 6) -> Bool {
        return count >= minLength
    }
    
    /// Validar si el string no está vacío después de quitar espacios
    var isNotEmpty: Bool {
        return !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Limpiar espacios en blanco al inicio y final
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
} 