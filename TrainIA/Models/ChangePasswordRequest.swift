import Foundation

struct ChangePasswordRequest: Codable {
    let current_password: String
    let new_password: String
} 