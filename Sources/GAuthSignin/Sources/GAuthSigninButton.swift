import UIKit
import WebKit

open class GAuthSigninButton: UIView {
    // MARK: - Properties
    private var client: String = ""
    private var redirect_url: String = ""
    private var code: String = ""
    private var button = UIButton(type: .custom)
    private var text: String?
    private struct Defaults {
        static let contentInset = UIEdgeInsets.zero
    }

    public init(
        clientId: String,
        redirect_uri: String
    ) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.client = clientId
        self.redirect_url = redirect_uri
        button.translatesAutoresizingMaskIntoConstraints = false
        configureUI()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        button.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        button.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        button.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 268).isActive = true
    }

    private func configureUI() {
        addSubview(button)
        afterView(auth: .signin, color: .outline, rounded: .default)
        button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
    }

    func afterView(auth: Auth, color: Color, rounded: Rounded) {
        switch auth {
        case .signin:
            let image = UIImage(named: "GAuthLogo", in: Bundle.module, compatibleWith: .none)?.withRenderingMode(.alwaysTemplate)
            button.setTitle("Sign in with GAuth", for: .normal)
            button.setImage(image, for: .normal)
            button.imageEdgeInsets = UIEdgeInsets(top: 16, left: 50, bottom: 16, right: 202)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            button.imageView?.contentMode = .scaleToFill
            button.semanticContentAttribute = .forceLeftToRight
        case .signup:
            let image = UIImage(named: "GAuthLogo", in: Bundle.module, compatibleWith: .none)?.withRenderingMode(.alwaysTemplate)
            button.setTitle("Sign up with GAuth", for: .normal)
            button.titleLabel?.font = UIFont(name: "Pretendard-SemiBold.otf", size: 17)
            button.setImage(image, for: .normal)
            button.imageEdgeInsets = UIEdgeInsets(top: 16, left: 50, bottom: 16, right: 202)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            button.imageView?.contentMode = .scaleToFill
            button.semanticContentAttribute = .forceLeftToRight
        case .continue:
            let image = UIImage(named: "GAuthLogo", in: Bundle.module, compatibleWith: .none)?.withRenderingMode(.alwaysTemplate)
            button.setTitle("Continue with GAuth", for: .normal)
            button.titleLabel?.font = UIFont(name: "Pretendard-SemiBold.otf", size: 17)
            button.setImage(image, for: .normal)
            button.imageEdgeInsets = UIEdgeInsets(top: 16, left: 50, bottom: 16, right: 202)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
            button.imageView?.contentMode = .scaleToFill
            button.semanticContentAttribute = .forceLeftToRight
        }
        switch color {
        case .white:
            button.setTitleColor(.main, for: .normal)
            button.imageView?.tintColor = .main
            button.backgroundColor = .white
        case .colored:
            button.setTitleColor(.white, for: .normal)
            button.tintColor = .white
            button.backgroundColor = .main
        case .outline:
            button.setTitleColor(.main, for: .normal)
            button.backgroundColor = .white
            button.tintColor = .main
            button.layer.borderWidth = 1
            if #available(iOS 13.0, *) {
                button.layer.borderColor = CGColor(red: 46/255, green: 128/255, blue: 204/255, alpha: 1)
            } else {
                // Fallback on earlier versions
            }
        }
        button.layer.cornerRadius = rounded == .rounded ? 24.75 : 6
    }

    @objc private func buttonDidTap() {
        let vc = self.getCurrentViewController() ?? nil
        let webView = WebViewController(client: client, redirect_url: redirect_url)
        webView.completionHandler = { code in
            self.code = code
        }
        vc?.present(webView, animated: true)
    }

    private func getCurrentViewController() -> UIViewController? {
       if let rootController = UIApplication.shared.keyWindow?.rootViewController {
           var currentController: UIViewController! = rootController
           while( currentController.presentedViewController != nil ) {
               currentController = currentController.presentedViewController
           }
           return currentController
       }
       return nil
   }
}

public struct GAuthSignin {
    public private(set) var text = "Hello, World!"

    public init() {
    }
}

@available(iOS 13.0, macOS 10.15, *)
extension Bundle {
    /// Gets the bundle for the SDK framework.
    /// - returns An optional instance of `Bundle`.
    /// - note If the main `Bundle` cannot be found, or if the `Bundle` cannot be
    /// found via a class, then this will return nil.
    static func gidFrameworkBundle() -> Bundle? {
        if let mainPath = Bundle.main.path(
            forResource: "GauthSignin",
            ofType: "bundle"
        ) {
            return Bundle(path: mainPath)
        }
        return nil
    }
        
        /// Retrieves the Google icon URL from the bundle.
        /// - parameter name: The `String` name for the resource to look up.
        /// - parameter ext: The `String` extension for the resource to look up.
        /// - returns An optional `URL` if the resource is found, nil otherwise.
        static func urlForGoogleResource(
            name: String,
            withExtension ext: String
        ) -> URL? {
            let bundle = Bundle.gidFrameworkBundle()
            return bundle?.url(forResource: name, withExtension: ext)
        }
    }
    
@available(iOS 13.0, macOS 10.15, *)
private extension UIFont {
  /// Load the font for the button.
  /// - returns A `Bool` indicating whether or not the font was loaded.
  static func loadCGFont() -> Bool {
    // Check to see if the font has already been loaded
#if os(iOS) || targetEnvironment(macCatalyst)
    if let _ = UIFont(name: "Pretendard-SemiBold", size: 17) {
      return true
    }
#elseif os(macOS)
    if let _ = NSFont(name: "Pretendard-SemiBold", size: 17) {
      return true
    }
#else
    fatalError("Unrecognized platform for SwiftUI sign in button font")
#endif
      guard let fontURL = Bundle.urlForGoogleResource(
      name: "Pretendard-SemiBold",
      withExtension: "ttf"
    ), let dataProvider = CGDataProvider(filename: fontURL.path),
          let newFont = CGFont(dataProvider) else {
            return false
          }
    return CTFontManagerRegisterGraphicsFont(newFont, nil)
  }
}

extension UIColor {
    class var main: UIColor? { return UIColor(named: "Main", in: Bundle.module, compatibleWith: .none) }
}
