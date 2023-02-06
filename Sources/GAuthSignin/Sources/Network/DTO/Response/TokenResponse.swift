import Foundation

public struct TokenResponse: Equatable, Decodable {
    public let accessToken: String
    public let refreshToken: String
}
