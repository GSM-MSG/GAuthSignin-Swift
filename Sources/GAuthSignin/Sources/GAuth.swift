import Foundation
import Combine

public class GAuth {
    public init() {}

    public func getGAuthTokenResponse(
        code: String,
        clientId: String,
        clientSecret: String,
        redirectUri: String
    ) async throws -> Result<TokenResponse, GAuthError> {
        let data = await OAuthAPI(user: .token(.init(code: code, clientId: clientId, clientSecret: clientSecret, redirectUri: redirectUri))).getToken()
        return data
    }

    public func getGAuthTokenResponsePublisher(
        code: String,
        clientId: String,
        clientSecret: String,
        redirectUri: String
    ) -> AnyPublisher<Result<TokenResponse, GAuthError>, Error> {
        let data = OAuthAPI(user: .token(.init(code: code, clientId: clientId, clientSecret: clientSecret, redirectUri: redirectUri))).getToken()
        return data
    }

    public func getGAuthTokenResponseClosure(code: String,
                                             clientId: String,
                                             clientSecret: String,
                                             redirectUri: String,
                                             completion: @escaping (Result<TokenResponse, GAuthError>) -> Void
    ) {
        OAuthAPI(user: .token(.init(code: code, clientId: clientId, clientSecret: clientSecret, redirectUri: redirectUri))).getToken() { response in
            completion(response)
        }
    }

    public func getGAuthCodeResponse(
        email: String,
        password: String
    ) async throws -> Result<String, GAuthError> {
        let code = await OAuthAPI(user: .code(.init(email: email, password: password))).getCode()
        return code
    }

    public func getGAuthCodeResponsePublisher(email: String, password: String) -> AnyPublisher<Result<String, GAuthError>, Error> {
        let code = OAuthAPI(user: .code(.init(email: email, password: password))).getCode()
        return code
    }

    public func getGAuthCodeResponseClosure(email: String, password: String, completion: @escaping (Result<String, GAuthError>) -> Void) {
        OAuthAPI(user: .code(.init(email: email, password: password))).getCode { code in
            completion(code)
        }
    }

    public func patchGAuthTokenResponse(
        refreshToken: String
    ) async throws -> Result<TokenResponse, GAuthError> {
        let data = await OAuthAPI(user: .refresh(refreshToken: refreshToken)).reissuance()
        return data
    }

    public func patchGAuthTokenResponsePublisher(refreshToken: String) -> AnyPublisher<Result<TokenResponse, GAuthError>, Error> {
        let data = OAuthAPI(user: .refresh(refreshToken: refreshToken)).reissuance()
        return data
    }

    public func patchGAuthTokenResponseClosure(refreshToken: String, completion: @escaping (Result<TokenResponse, GAuthError>) -> Void) {
        OAuthAPI(user: .refresh(refreshToken: refreshToken)).reissuance() { response in
            completion(response)
        }
    }

    public func getGAuthUserInfoResponse(
        accessToken: String
    ) async throws -> Result<UserInfoResponse, GAuthError> {
        let result = await UserAPI(user: .user(accessToken: accessToken)).authorization()
        return result
    }

    public func getGAuthUserInfoResponsePublisher(accessToken: String) -> AnyPublisher<Result<UserInfoResponse, GAuthError>, Error> {
        let data = UserAPI(user: .user(accessToken: accessToken)).authorization()
        return data
    }

    public func getGAuthUserInfoResponseClosure(accessToken: String, _ completion: @escaping (Result<UserInfoResponse, GAuthError>) -> Void) {
        UserAPI(user: .user(accessToken: accessToken)).authorization { response in
            completion(response)
        }
    }
}
