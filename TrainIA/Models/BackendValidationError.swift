import Foundation

struct BackendValidationError: Error {
    let message: String
    let fieldErrors: [String: [String]]
} 