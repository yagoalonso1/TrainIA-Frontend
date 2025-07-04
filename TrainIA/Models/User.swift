import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let avatarUrl: String
    let role: String
    let subscriptionStatus: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, role
        case avatarUrl = "avatar_url"
        case subscriptionStatus = "subscription_status"
    }
} 