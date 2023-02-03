import Foundation
import Combine

enum OAuthEnum {
    case code(AuthInfoDTO)
    case token(ServiceInfoDTO)
    case refresh(refreshToken: String)
}

@available(iOS 13.0, *)
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

    func reissuance() async -> TokenDTO {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = httpMethod
        urlRequest.httpBody = jsonData
        urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "refreshToken")
        return .init(accessToken: "", refreshToken: "")
    }

    func getCode() async -> String {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = httpMethod
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        let code = try? await codeTask(urlRequest: urlRequest)
        return code ?? ""
    }

    func getToken() async -> TokenDTO {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = httpMethod
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        let token = try? await tokenTask(urlRequest: urlRequest)
        return token ?? .init(accessToken: "", refreshToken: "")
    }

    func tokenTask(urlRequest: URLRequest) async throws -> TokenDTO {
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw GAuthError.unknown
        }
        let res = try JSONDecoder().decode(TokenDTO.self, from: data)
        return res
    }

    func codeTask(urlRequest: URLRequest) async throws -> String {
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300) ~= httpResponse.statusCode else {
            throw GAuthError.unknown
        }
        var codes: String = ""
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
            if let name = json["code"] as? String {
                codes = name
            }
        }
        return codes
    }

    func reissuanceTask(urlRequest: URLRequest) async throws -> TokenDTO {
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw GAuthError.unknown
        }
        let res = try JSONDecoder().decode(TokenDTO.self, from: data)
        return res
    }

    func reissuance() -> AnyPublisher<TokenDTO, Error> {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = httpMethod
        urlRequest.httpBody = jsonData
        urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "refreshToken")
        return reissuanceTask(urlRequest: urlRequest)
    }

    func reissuance(_ completion: @escaping (TokenDTO) -> Void) {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = httpMethod
        urlRequest.httpBody = jsonData
        urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "refreshToken")
        return reissuanceTask(urlRequest: urlRequest) { response in
            completion(response)
        }
    }

    func getCode() -> AnyPublisher<String, Error> {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = httpMethod
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        return codeTask(urlRequest: urlRequest)
    }

    func getCode(_ completion: @escaping (String) -> Void) {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = httpMethod
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        return codeTask(urlRequest: urlRequest) { response in
            completion(response)
        }
    }

    func getToken() -> AnyPublisher<TokenDTO, Error> {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = httpMethod
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        return tokenTask(urlRequest: urlRequest)
    }

    func getToken(_ completion: @escaping (TokenDTO) -> Void) {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = httpMethod
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        return tokenTask(urlRequest: urlRequest) { response in
            completion(response)
        }
    }

    func reissuanceTask(urlRequest: URLRequest) -> AnyPublisher<TokenDTO, Error> {
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .mapError { error -> Error in
                return GAuthError.unknown
            }
            .tryMap { (data, response) -> (data: Data, response: URLResponse) in
                guard let urlResponse = response as? HTTPURLResponse else {
                    throw GAuthError.unknown
                }
                if (200..<300) ~= urlResponse.statusCode {
                }
                else {
                    print(urlResponse.statusCode)
                }
                return (data, response)
            }
            .map(\.data)
            .decode(type: TokenDTO.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    func reissuanceTask(urlRequest: URLRequest, _ completion: @escaping (TokenDTO) -> Void) {
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }

                DispatchQueue.main.async {
                    do {
                        let res = try JSONDecoder().decode(TokenDTO.self, from: data!)

                        completion(res)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
            .resume()
    }

    func tokenTask(urlRequest: URLRequest) -> AnyPublisher<TokenDTO, Error> {
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .mapError { error -> Error in
                return GAuthError.unknown
            }
            .tryMap { (data, response) -> (data: Data, response: URLResponse) in
                guard let urlResponse = response as? HTTPURLResponse else {
                    throw GAuthError.unknown
                }
                if (200..<300) ~= urlResponse.statusCode {
                }
                else {
                    print(urlResponse.statusCode)
                }
                return (data, response)
            }
            .map(\.data)
            .decode(type: TokenDTO.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    func tokenTask(urlRequest: URLRequest, _ completion: @escaping (TokenDTO) -> Void) {
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }

                DispatchQueue.main.async {
                    do {
                        let res = try JSONDecoder().decode(TokenDTO.self, from: data!)

                        completion(res)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
            .resume()
    }

    func codeTask(urlRequest: URLRequest) -> AnyPublisher<String, Error> {
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .mapError { error -> Error in
                return GAuthError.unknown
            }
            .tryMap { (data, response) -> String in
                guard let urlResponse = response as? HTTPURLResponse else {
                    throw GAuthError.unknown
                }
                if (200..<300) ~= urlResponse.statusCode {
                }
                else {
                    print(urlResponse.statusCode)
                }
                var codes: String = ""
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                    if let name = json["code"] as? String {
                        codes = name
                    }
                }
                return codes
            }
            .eraseToAnyPublisher()
    }

    func codeTask(urlRequest: URLRequest, _ completion: @escaping (String) -> Void) {
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    print(error.localizedDescription)
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

                        completion(codes)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
            .resume()
    }
}
