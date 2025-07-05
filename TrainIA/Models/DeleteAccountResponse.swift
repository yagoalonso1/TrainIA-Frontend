import Foundation

struct DeleteAccountResponse: Codable {
    let success: Bool
    let message: String
    let data: DeleteAccountData?
}

struct DeleteAccountData: Codable {
    let user_id: Int?
    let email: String?
    let deleted_at: String?
    let data_cleaned: Bool?
} 