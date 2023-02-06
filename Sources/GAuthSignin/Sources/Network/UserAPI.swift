import Foundation
import Combine

enum UserAPIEnum {
    case user(accessToken: String)
}

class UserAPI {
    let baseURL: String = "https://open.gauth.co.kr/"
    let user: UserAPIEnum

    init(user: UserAPIEnum) {
        self.user = user
    }
    
    var urlPath: String {
        switch user {
        case .user:
            return "user"
        }
    }

    var token: String {
        switch user {
        case let .user(accessToken):
            return accessToken
        }
    }

    var errorMap: [Int: GAuthError] {
        switch user {
        case .user:
            return [
                400: .clientSecretMismatch,
                401: .tokenExpriedOrDeterioration,
                404: .notFoundRegisteredService,
                500: .internalServerError
            ]
        }
    }

    func authorization() async -> Result<UserInfoResponse, GAuthError> {
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        let result = try? await authorizationTask(urlRequest: urlRequest)
        return result ?? .failure(.unknown())
    }

    func authorization(_ completion: @escaping (Result<UserInfoResponse, GAuthError>) -> Void) {
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        authorizationTask(urlRequest: urlRequest) { result in
            completion(result)
        }
    }

    func authorization() -> AnyPublisher<Result<UserInfoResponse, GAuthError>, Error> {
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        return authorizationTask(urlRequest: urlRequest)
    }

    func authorizationTask(urlRequest: URLRequest) async throws -> Result<UserInfoResponse, GAuthError> {
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GAuthError.unknown()
        }

        do {
            let res = try JSONDecoder().decode(UserInfoResponse.self, from: data)
            return .success(res)
        } catch {
            return .failure(self.errorMap[httpResponse.statusCode]?.asGAuthError ?? .unknown())
        }
    }

    func authorizationTask(urlRequest: URLRequest, _ completion: @escaping (Result<UserInfoResponse, GAuthError>) -> Void) {
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let urlResponse = response as? HTTPURLResponse else {
                return
            }
            
            DispatchQueue.main.async {
                do {
                    let res = try JSONDecoder().decode(UserInfoResponse.self, from: data!)
                    completion(.success(res))
                } catch {
                    completion(.failure(self.errorMap[urlResponse.statusCode]?.asGAuthError ?? .unknown()))
                }
            }
        }
        .resume()
    }

    func authorizationTask(urlRequest: URLRequest) -> AnyPublisher<Result<UserInfoResponse, GAuthError>, Error> {
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { response -> Result<UserInfoResponse, GAuthError> in
                guard let urlResponse = response.response as? HTTPURLResponse else {
                    throw GAuthError.unknown()
                }
                if (200..<300) ~= urlResponse.statusCode {
                    let data = try JSONDecoder().decode(UserInfoResponse.self, from: response.data)
                    return (.success(data))
                }
                else {
                    return (.failure(self.errorMap[urlResponse.statusCode]?.asGAuthError ?? .unknown()))
                }
            }
            .mapError { error -> GAuthError in
                error as? GAuthError ?? .unknown()
            }
            .eraseToAnyPublisher()
    }
}
