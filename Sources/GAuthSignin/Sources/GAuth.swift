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

    public func getGAuthTokenResponseClosure(code: String,
                                             clientId: String,
                                             clientSecret: String,
                                             redirectUri: String,
                                             completion: @escaping (TokenDTO) -> Void
    ) {
        OAuthAPI(user: .token(.init(code: code, clientId: clientId, clientSecret: clientSecret, redirectUri: redirectUri))).getToken() { response in
            completion(response)
        }
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

    public func getGAuthCodeResponseClosure(email: String, password: String, completion: @escaping (String) -> Void) {
        OAuthAPI(user: .code(.init(email: email, password: password))).getCode { code in
            completion(code)
        }
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

    public func patchGAuthTokenResponseClosure(refreshToken: String, completion: @escaping (TokenDTO) -> Void) {
        OAuthAPI(user: .refresh(refreshToken: refreshToken)).reissuance() { response in
            completion(response)
        }
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

    public func getGAuthUserInfoResponseClosure(accessToken: String, completion: @escaping (UserInfoDTO) -> Void) {
        UserAPI(user: .user(accessToken: accessToken)).authorization { response in
            completion(response)
        }
    }
}
