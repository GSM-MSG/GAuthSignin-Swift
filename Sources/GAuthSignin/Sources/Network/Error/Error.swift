import Foundation

public enum GAuthError: Error, Equatable {
    case unknown(message: String = "알 수 없는 에러가 발생했습니다")

    // global
    case internalServerError

    // code
    case passwordMismatch
    case notFoundUserByEmail

    // token
    case clientSecretMismatch
    case tokenExpriedOrDeterioration
    case notFoundServiceByClientId

    // refresh
    case notFoundUserByToken

    // user
    case notFoundRegisteredService
}

extension GAuthError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .unknown(message):
            return message

        case .internalServerError:
            return "서버에서 문제가 발생했습니다"

        // MARK: - code
        case .passwordMismatch:
            return "비밀번호가 미일치합니다"

        case .notFoundUserByEmail:
            return "이메일에 따른 유저를 찾지 못했습니다"

        // MARK: - token
        case .clientSecretMismatch:
            return "clientSecret이 일치하지 않습니다"
        case .tokenExpriedOrDeterioration:
            return "토큰이 변질되거나 만료 되었습니다"
        case .notFoundServiceByClientId:
            return "clientId에 따른 서비스를 찾지 못했습니다"

        // MARK: - refresh
        case .notFoundUserByToken:
            return "토큰에 따른 유저를 찾지 못했습니다"

        // MARK: - user
        case .notFoundRegisteredService:
            return "등록된 서비스를 찾지 못했습니다"
        }
    }
}

extension Error {
    var asGAuthError: GAuthError {
        self as? GAuthError ?? .unknown()
    }
}
