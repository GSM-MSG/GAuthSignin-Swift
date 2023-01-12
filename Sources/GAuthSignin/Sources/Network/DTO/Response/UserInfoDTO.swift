import Foundation

public struct UserInfoDTO: Decodable, Encodable {
    public var email: String
    public var name: String?
    public var grade: Int?
    public var classNum: Int?
    public var num: Int?
    public var gender: String
    public var profileUrl: String?
    public var role: String
}
