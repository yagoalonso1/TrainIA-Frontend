import Foundation

struct ChangePasswordResponse: Codable {
    let success: Bool
    let message: String
    let data: ChangePasswordData?
}


