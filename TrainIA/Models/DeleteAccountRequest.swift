import Foundation

struct DeleteAccountRequest: Codable {
    let password: String
    let confirm_deletion: Bool
} 