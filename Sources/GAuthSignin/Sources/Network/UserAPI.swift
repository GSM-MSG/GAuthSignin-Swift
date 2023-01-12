import Foundation

enum UserAPIEnum {
    case code(AuthInfoDTO)
    case token(ServiceInfoDTO)
    case refresh
}

struct UserAPI {
    let baseURL: String = "https://server.gauth.co.kr/oauth/"
    let user: UserAPIEnum

    init(user: UserAPIEnum) {
        self.user = user
    }

    var urlPath: String {
        switch user {
        case .code:
            return "code"
        case .token:
            return "token"
        case .refresh:
            return "refresh"
        }
    }
    var json: [String: Any] {
        switch user {
        case let .code(req):
            return [
                "email": req.email,
                "passwrod": req.password
            ]
        case let .token(req):
            return [
                "code" : req.code,
                "clientId" : req.clientId,
                "clientSecret" : req.clientSecret,
                "redirectUri" : req.redirectUri
            ]
        case .refresh:
            return [:]
        }
    }

    @available(iOS 13.0, *)
    func getToken() async -> TokenDTO {
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        let token = try? await task(urlRequest: urlRequest)
        return token ?? .init(accessToken: "123", refreshToken: "13")
    }

    func task(urlRequest: URLRequest) async throws -> TokenDTO {
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
