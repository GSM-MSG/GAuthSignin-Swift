import Foundation

enum UserAPIEnum {
    case user(accessToken: String)
}

struct UserAPI {
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

    @available(iOS 13.0, *)
    func authorization() async -> UserInfoDTO {
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        let token = try? await authorizationTask(urlRequest: urlRequest)
        return token ?? .init(email: "", gender: "", role: "")
    }

    func authorizationTask(urlRequest: URLRequest) async throws -> UserInfoDTO {
        if #available(iOS 13.0, *) {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print((response as? HTTPURLResponse)?.statusCode)
                throw GAuthError.unknown
            }
            let res = try JSONDecoder().decode(UserInfoDTO.self, from: data)
            return res
        } else {
            return .init(email: "", gender: "", role: "")
        }
    }
}
