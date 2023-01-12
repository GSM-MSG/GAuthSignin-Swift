import Foundation

enum OAuthEnum {
    case code(AuthInfoDTO)
    case token(ServiceInfoDTO)
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

    @available(iOS 13.0, *)
    func reissuance() async -> TokenDTO {
//        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = "PATCH"
//        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "refreshToken")
        let token = try? await reissuanceTask(urlRequest: urlRequest)
        return token ?? .init(accessToken: "", refreshToken: "")
    }

    @available(iOS 13.0, *)
    func getCode() async -> String {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        let code = try? await codeTask(urlRequest: urlRequest)
        return code ?? ""
    }

    @available(iOS 13.0, *)
    func getToken() async -> TokenDTO {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        let token = try? await tokenTask(urlRequest: urlRequest)
        return token ?? .init(accessToken: "", refreshToken: "")
    }

    func tokenTask(urlRequest: URLRequest) async throws -> TokenDTO {
        if #available(iOS 13.0, *) {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw GAuthError.unknown
            }
            let res = try JSONDecoder().decode(TokenDTO.self, from: data)
            return res
        } else {
            return .init(accessToken: "", refreshToken: "")
        }
    }

    func codeTask(urlRequest: URLRequest) async throws -> String {
        if #available(iOS 13.0, *) {
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
        } else {
            return ""
        }
    }

    func reissuanceTask(urlRequest: URLRequest) async throws -> TokenDTO {
        if #available(iOS 13.0, *) {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw GAuthError.unknown
            }
            let res = try JSONDecoder().decode(TokenDTO.self, from: data)
            return res
        } else {
            return .init(accessToken: "", refreshToken: "")
        }
    }
}
