import Foundation

open class GAuth {
    private var code: String = ""
    public init() {}

    public func getGAuthTokenRequest(
        code: String,
        clientId: String,
        clientSecret: String,
        redirectUri: String
    ) async throws {
        if #available(iOS 13.0, *) {
            let data = try? await UserAPI(user: .token(.init(code: code, clientId: clientId, clientSecret: clientSecret, redirectUri: redirectUri))).getToken()
//            return data!
        } else {
//            return .init(accessToken: "", refreshToken: "")
        }
    }

    func getCode(code: String) {
        self.code = code
    }
}
