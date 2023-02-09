#if canImport(UIKit) && canImport(WebKit)
import UIKit
import WebKit

final class GAuthSigninWebViewController: UIViewController, WKNavigationDelegate {
    private lazy var wkWebView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        webConfiguration.preferences = preferences
        let wkWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        return wkWebView
    }()
    private let clientID: String
    private let redirectURI: String
    private let completion: (String) -> Void

    init(
        clientID: String,
        redirectURI: String,
        completion: @escaping (String) -> Void
    ) {
        self.clientID = clientID
        self.redirectURI = redirectURI
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(wkWebView)
        NSLayoutConstraint.activate([
            wkWebView.topAnchor.constraint(equalTo: view.topAnchor),
            wkWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wkWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            wkWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        wkWebView.navigationDelegate = self
        wkWebView.allowsBackForwardNavigationGestures = true
        wkWebView.allowsLinkPreview = true
        DispatchQueue.main.async {
            var components = URLComponents(string: "https://gauth.co.kr/login")!
            components.queryItems = [
                URLQueryItem(name: "client_id", value: self.clientID),
                URLQueryItem(name: "redirect_uri", value: self.redirectURI)
            ]
            let request = URLRequest(url: components.url!)
            self.wkWebView.load(request)
        }
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        let urlString = navigationAction.request.url?.absoluteString ?? ""
        if urlString.contains("code=") {
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    self.completion(urlString.components(separatedBy: "code=")[1])
                }
            }
        }
        decisionHandler(.allow)
    }
}
#endif
