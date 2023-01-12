import Foundation

struct ServiceInfoDTO: Encodable, Decodable {
    let code: String
    let clientId: String
    let clientSecret: String
    let redirectUri: String
}
