import Foundation

struct LoginData: Codable {
    let user: User
    let token: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case user, token
        case tokenType = "token_type"
    }
}