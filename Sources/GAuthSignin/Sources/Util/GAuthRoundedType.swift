import UIKit

public enum GAuthRoundedType: Hashable {
    case `default`
    case rounded
}

extension GAuthRoundedType {
    public var cornerRadius: CGFloat {
        switch self {
        case .`default`:
            return 6

        case .rounded:
            return 24.75
        }
    }
}
