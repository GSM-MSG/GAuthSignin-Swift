import Foundation

public struct TokenDTO: Equatable, Decodable {
    public let accessToken: String
    public let refreshToken: String
}
