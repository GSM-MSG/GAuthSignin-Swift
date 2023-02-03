import Foundation
import Combine

@available(iOS 13.0, *)
public class GAuth {
    public init() {}

    public func getGAuthTokenResponse(
        code: String,
        clientId: String,
        clientSecret: String,
        redirectUri: String
    ) async throws -> TokenDTO {
        let data = await OAuthAPI(user: .token(.init(code: code, clientId: clientId, clientSecret: clientSecret, redirectUri: redirectUri))).getToken()
        return data
    }

    public func getGAuthTokenResponsePublisher(
        code: String,
        clientId: String,
        clientSecret: String,
        redirectUri: String
    ) -> AnyPublisher<TokenDTO, Error> {
        let data = OAuthAPI(user: .token(.init(code: code, clientId: clientId, clientSecret: clientSecret, redirectUri: redirectUri))).getToken()
        return data
    }

    public func getGAuthCodeResponse(
        email: String,
        password: String
    ) async throws -> String {
        let code = await OAuthAPI(user: .code(.init(email: email, password: password))).getCode()
        return code
    }

    public func getGAuthCodeResponsePublisher(email: String, password: String) -> AnyPublisher<String, Error> {
        let code = OAuthAPI(user: .code(.init(email: email, password: password))).getCode()
        return code
    }

    public func patchGAuthTokenResponse(
        refreshToken: String
    ) async throws -> TokenDTO {
        let data = await OAuthAPI(user: .refresh(refreshToken: refreshToken)).reissuance()
        return data
    }

    public func patchGAuthTokenResponsePublisher(refreshToken: String) -> AnyPublisher<TokenDTO, Error> {
        let data = OAuthAPI(user: .refresh(refreshToken: refreshToken)).reissuance()
        return data
    }

    public func getGAuthUserInfoResponse(
        accessToken: String
    ) async throws -> UserInfoDTO {
        let data = await UserAPI(user: .user(accessToken: accessToken)).authorization()
        return data
    }

    public func getGAuthUserInfoResponsePublisher(accessToken: String) -> AnyPublisher<UserInfoDTO, Error> {
        let data = UserAPI(user: .user(accessToken: accessToken)).authorizationTask()
        return data
    }
}
