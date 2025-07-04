import Foundation

struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let data: LoginData
}