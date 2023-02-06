import UIKit

public enum GAuthType: String {
    case signin
    case signup
    case `continue`
}

extension GAuthType {
    public var description: String {
        switch self {
        case .signin:
            return "Sign in with GAuth"

        case .signup:
            return "Sign up with GAuth"

        case .continue:
            return "Continue with GAuth"
        }
    }
}
