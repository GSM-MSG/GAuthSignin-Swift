import Foundation
import Combine

enum OAuthEnum {
    case code(AuthInfoRequestDTO)
    case token(ServiceInfoRequestDTO)
    case refresh(refreshToken: String)
}

struct OAuthAPI {
    let baseURL: String = "https://server.gauth.co.kr/oauth/"
    let user: OAuthEnum

    init(user: OAuthEnum) {
        self.user = user
    }

    var urlPath: String {
        switch user {
        case .code:
            return "code"
        case .token, .refresh:
            return "token"
        }
    }

    var json: [String: Any] {
        switch user {
        case let .code(req):
            return [
                "email": req.email + "@gsm.hs.kr",
                "password": req.password
            ]
        case let .token(req):
            return [
                "code" : req.code,
                "clientId" : req.clientId,
                "clientSecret" : req.clientSecret,
                "redirectUri" : req.redirectUri
            ]
        default:
            return [:]
        }
    }

    var token: String {
        switch user {
        case let .refresh(refreshToken):
            return refreshToken
        case .code, .token:
            return ""
        }
    }

    var httpMethod: String {
        switch user {
        case .token, .code:
            return "POST"
        case .refresh:
            return "PATCH"
        }
    }

    var errorMap: [Int: GAuthError] {
        switch user {
        case .code:
            return [
                400: .passwordMismatch,
                404: .notFoundUserByEmail,
                500: .internalServerError
            ]
        case .token:
            return [
                400: .clientSecretMismatch,
                401: .tokenExpriedOrDeterioration,
                404: .notFoundServiceByClientId,
                500: .internalServerError
            ]
        case .refresh:
            return [
                401: .tokenExpriedOrDeterioration,
                404: .notFoundUserByToken,
                500: .internalServerError
            ]
        }
    }

    func reissuance() async -> Result<TokenResponse, GAuthError> {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = httpMethod
        urlRequest.httpBody = jsonData
        urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "refreshToken")
        let result = try? await reissuanceTask(urlRequest: urlRequest)
        return result ?? .failure(.unknown())
    }

    func reissuance() -> AnyPublisher<Result<TokenResponse, GAuthError>, Error> {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = httpMethod
        urlRequest.httpBody = jsonData
        urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "refreshToken")
        return reissuanceTask(urlRequest: urlRequest)
    }

    func reissuance(_ completion: @escaping (Result<TokenResponse, GAuthError>) -> Void) {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = httpMethod
        urlRequest.httpBody = jsonData
        urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "refreshToken")
        return reissuanceTask(urlRequest: urlRequest) { response in
            completion(response)
        }
    }

    func getCode() async -> Result<String, GAuthError> {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = httpMethod
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        let code = try? await codeTask(urlRequest: urlRequest)
        return code ?? .failure(.unknown())
    }

    func getCode() -> AnyPublisher<Result<String, GAuthError>, Error> {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = httpMethod
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        return codeTask(urlRequest: urlRequest)
    }

    func getCode(_ completion: @escaping (Result<String, GAuthError>) -> Void) {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = httpMethod
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        return codeTask(urlRequest: urlRequest) { response in
            completion(response)
        }
    }

    func getToken() async -> Result<TokenResponse, GAuthError> {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = httpMethod
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        let token = try? await tokenTask(urlRequest: urlRequest)
        return token ?? .failure(.unknown())
    }

    func getToken() -> AnyPublisher<Result<TokenResponse, GAuthError>, Error> {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = httpMethod
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        return tokenTask(urlRequest: urlRequest)
    }

    func getToken(_ completion: @escaping (Result<TokenResponse, GAuthError>) -> Void) {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = httpMethod
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        return tokenTask(urlRequest: urlRequest) { response in
            completion(response)
        }
    }

    func reissuanceTask(urlRequest: URLRequest) async throws -> Result<TokenResponse, GAuthError> {
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GAuthError.unknown()
        }

        do {
            let res = try JSONDecoder().decode(TokenResponse.self, from: data)
            return .success(res)
        } catch {
            return .failure(self.errorMap[httpResponse.statusCode]?.asGAuthError ?? .unknown())
        }
    }

    func reissuanceTask(urlRequest: URLRequest) -> AnyPublisher<Result<TokenResponse, GAuthError>, Error> {
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { response -> Result<TokenResponse, GAuthError> in
                guard let urlResponse = response.response as? HTTPURLResponse else {
                    throw GAuthError.unknown()
                }
                if (200..<300) ~= urlResponse.statusCode {
                    let data = try JSONDecoder().decode(TokenResponse.self, from: response.data)
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

    func reissuanceTask(urlRequest: URLRequest, _ completion: @escaping (Result<TokenResponse, GAuthError>) -> Void) {
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let urlResponse = response as? HTTPURLResponse else {
                return
            }
            
            DispatchQueue.main.async {
                do {
                    let res = try JSONDecoder().decode(TokenResponse.self, from: data!)
                    completion(.success(res))
                } catch {
                    completion(.failure(self.errorMap[urlResponse.statusCode]?.asGAuthError ?? .unknown()))
                }
            }
        }
        .resume()
    }

    func tokenTask(urlRequest: URLRequest) async throws -> Result<TokenResponse, GAuthError> {
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GAuthError.unknown()
        }

        do {
            let res = try JSONDecoder().decode(TokenResponse.self, from: data)
            return .success(res)
        } catch {
            return .failure(self.errorMap[httpResponse.statusCode]?.asGAuthError ?? .unknown())
        }
    }

    func tokenTask(urlRequest: URLRequest) -> AnyPublisher<Result<TokenResponse, GAuthError>, Error> {
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { response -> Result<TokenResponse, GAuthError> in
                guard let urlResponse = response.response as? HTTPURLResponse else {
                    throw GAuthError.unknown()
                }
                if (200..<300) ~= urlResponse.statusCode {
                    let data = try JSONDecoder().decode(TokenResponse.self, from: response.data)
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

    func tokenTask(urlRequest: URLRequest, _ completion: @escaping (Result<TokenResponse, GAuthError>) -> Void) {
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let urlResponse = response as? HTTPURLResponse else {
                return
            }
            
            DispatchQueue.main.async {
                do {
                    let res = try JSONDecoder().decode(TokenResponse.self, from: data!)
                    completion(.success(res))
                } catch {
                    completion(.failure(self.errorMap[urlResponse.statusCode]?.asGAuthError ?? .unknown()))
                }
            }
        }
        .resume()
    }

    func codeTask(urlRequest: URLRequest) async throws -> Result<String, GAuthError> {
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GAuthError.unknown()
        }

        do {
            var codes: String = ""
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                if let name = json["code"] as? String {
                    codes = name
                }
            }
            return .success(codes)
        } catch {
            return .failure(self.errorMap[httpResponse.statusCode]?.asGAuthError ?? .unknown())
        }
    }

    func codeTask(urlRequest: URLRequest) -> AnyPublisher<Result<String, GAuthError>, Error> {
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response -> Result<String, GAuthError> in
                guard let urlResponse = response as? HTTPURLResponse else {
                    throw GAuthError.unknown()
                }
                if (200..<300) ~= urlResponse.statusCode {
                    var codes: String = ""
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                        if let name = json["code"] as? String {
                            codes = name
                        }
                    }
                    return (.success(codes))
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

    func codeTask(urlRequest: URLRequest, _ completion: @escaping (Result<String, GAuthError>) -> Void) {
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let urlResponse = response as? HTTPURLResponse else {
                return
            }
            
            DispatchQueue.main.async {
                do {
                    var codes: String = ""
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any] {
                        if let name = json["code"] as? String {
                            codes = name
                        }
                    }
                    completion(.success(codes))
                } catch {
                    completion(.failure(self.errorMap[urlResponse.statusCode]?.asGAuthError ?? .unknown()))
                }
            }
        }
        .resume()
    }
}
