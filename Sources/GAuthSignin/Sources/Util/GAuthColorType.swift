import UIKit

public enum GAuthColorType: Hashable {
    case white
    case colored
    case outline
}

extension GAuthColorType {
    public var tintColor: UIColor {
        switch self {
        case .white, .outline:
            return .main

        case .colored:
            return .white
        }
    }

    public var backgroundColor: UIColor {
        switch self {
        case .white, .outline:
            return .white

        case .colored:
            return .main
        }
    }
}
