#if canImport(UIKit)
import UIKit

public final class GAuthButton: UIButton {
    private var clientID: String?
    private var redirectURI: String?
    private var targetViewController: UIViewController?
    private var completion: ((String) -> Void)?

    public init(
        auth: GAuthType = .signin,
        color: GAuthColorType = .white,
        rounded: GAuthRoundedType = .default
    ) {
        super.init(frame: .zero)
        registerFont()
        reigsterAction()
        configureUI(auth: auth, color: color, rounded: rounded)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func prepare(
        clientID: String,
        redirectURI: String,
        presenting viewController: UIViewController,
        completion: @escaping (_ code: String) -> Void
    ) {
        self.clientID = clientID
        self.redirectURI = redirectURI
        self.targetViewController = viewController
        self.completion = completion
    }
}

private extension GAuthButton {
    func registerFont() {
        guard let url = Bundle.module.url(forResource: "Pretendard-SemiBold.otf", withExtension: nil) else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }

    func reigsterAction() {
        self.addTarget(self, action: #selector(signinButtonDidTap), for: .touchUpInside)
    }

    func configureUI(auth: GAuthType, color: GAuthColorType, rounded: GAuthRoundedType) {
        let image = UIImage(named: "GAuthLogo", in: Bundle.module, compatibleWith: .none)?
            .withTintColor(color.tintColor, renderingMode: .alwaysTemplate)

        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.filled()
            configuration.image = image
            configuration.baseForegroundColor = color.tintColor
            configuration.baseBackgroundColor = color.backgroundColor
            configuration.imagePadding = 10
            configuration.background.cornerRadius = rounded.cornerRadius
            configuration.cornerStyle = .fixed

            var attrubutedTitle = AttributedString(auth.description)
            attrubutedTitle.font = .init(name: "Pretendard-SemiBold", size: 17)
            configuration.attributedTitle = attrubutedTitle
            self.configuration = configuration
        } else {
            self.setImage(image, for: .normal)
            self.setTitle(auth.description, for: .normal)
            self.setTitleColor(color.tintColor, for: .normal)
            self.backgroundColor = color.backgroundColor
            self.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 17)
            self.imageView?.contentMode = .scaleAspectFit
        }
        self.layer.cornerRadius = rounded.cornerRadius
        if color == .outline {
            self.layer.borderWidth = 1
            self.layer.borderColor = color.tintColor.cgColor
        }
    }

    @objc func signinButtonDidTap() {
        guard
            let targetViewController,
            let clientID,
            let redirectURI,
            let completion
        else {
            fatalError(
                "Please prepare property 'targetViewController, clientID, redirectURI, completion' using method 'prepare(clientID:redirectURI:presenting:completion:)'"
            )
        }
        let webVC = GAuthSigninWebViewController(
            clientID: clientID,
            redirectURI: redirectURI
        ) { code in
            completion(code)
        }
        DispatchQueue.main.async {
            targetViewController.present(webVC, animated: true)
        }
    }
}

extension UIColor {
    static let main: UIColor = UIColor(named: "Main", in: Bundle.module, compatibleWith: .none) ?? .init()
}
#endif
