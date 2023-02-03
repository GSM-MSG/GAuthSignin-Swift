import Foundation
import Combine

enum UserAPIEnum {
    case user(accessToken: String)
}

@available(iOS 13.0, *)
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

    func authorization() async -> UserInfoDTO {
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        let token = try? await authorizationTask(urlRequest: urlRequest)
        return token ?? .init(email: "", gender: "", role: "")
    }

    func authorization(_ completion: @escaping (UserInfoDTO) -> Void) {
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        authorizationTask(urlRequest: urlRequest) { response in
            completion(response)
        }
    }

    func authorizationTask(urlRequest: URLRequest) async throws -> UserInfoDTO {
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw GAuthError.unknown
        }
        let res = try JSONDecoder().decode(UserInfoDTO.self, from: data)
        return res
    }

    func authorizationTask(urlRequest: URLRequest, _ completion: @escaping (UserInfoDTO) -> Void) {
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }

                DispatchQueue.main.async {
                    do {
                        let res = try JSONDecoder().decode(UserInfoDTO.self, from: data!)

                        completion(res)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
            .resume()
    }

    func authorizationTask() -> AnyPublisher<UserInfoDTO, Error> {
        var urlRequest = URLRequest(url: (URL(string: baseURL + urlPath) ?? URL(string: ""))!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
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
            .decode(type: UserInfoDTO.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
