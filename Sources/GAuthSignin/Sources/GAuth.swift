import Foundation

public class GAuth {
    public init() {}

    public func getGAuthTokenResponse(
        code: String,
        clientId: String,
        clientSecret: String,
        redirectUri: String
    ) async throws -> TokenDTO {
        if #available(iOS 13.0, *) {
            let data = try? await OAuthAPI(user: .token(.init(code: code, clientId: clientId, clientSecret: clientSecret, redirectUri: redirectUri))).getToken()
            return data!
        } else {
            return .init(accessToken: "", refreshToken: "")
        }
    }

    public func getGAuthCodeResponse(
        email: String,
        password: String
    ) async throws -> String {
        if #available(iOS 13.0, *) {
            let code = try? await OAuthAPI(user: .code(.init(email: email, password: password))).getCode()
            return code!
        } else {
            return ""
        }
    }

    public func patchGAuthTokenResponse(
        refreshToken: String
    ) async throws -> TokenDTO {
        if #available(iOS 13.0, *) {
            let data = try? await OAuthAPI(user: .refresh(refreshToken: refreshToken)).reissuance()
            return data!
        } else {
            return .init(accessToken: "", refreshToken: "")
        }
    }

    public func getGAuthUserInfoResponse(
        accessToken: String
    ) async throws -> UserInfoDTO {
        if #available(iOS 13.0, *) {
            let data = try? await UserAPI(user: .user(accessToken: accessToken)).authorization()
            return data!
        } else {
            return .init(email: "", gender: "", role: "")
        }
    }
}
