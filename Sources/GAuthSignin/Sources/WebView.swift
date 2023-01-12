import UIKit
import WebKit

final class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    var webView = WKWebView()
    var completionHandler: ((String) -> ())?
    private let client: String
    private let redirect_url: String

    init(client: String, redirect_url: String) {
        self.client = client
        self.redirect_url = redirect_url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        webConfiguration.preferences = preferences
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        DispatchQueue.main.async {
            var components = URLComponents(string: "https://gauth.co.kr/login")!
            components.queryItems = [ URLQueryItem(name: "client_id", value: self.client), URLQueryItem(name: "redirect_uri", value: self.redirect_url) ]
            let request = URLRequest(url: components.url!)
            self.webView.load(request)
        }
    }
    
    func getPostString(params:[String:String]) -> String
    {
        var data = [String]()
        for(key, value) in params
        {
            data.append(key + "=\(value)")
        }
        return data.map { String($0) }.joined(separator: "&")
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let urlString = navigationAction.request.url?.absoluteString ?? ""
        if urlString.contains("code=") {
            completionHandler?(urlString.components(separatedBy: "code=")[1])
            dismiss(animated: true)
        }
        decisionHandler(.allow)
    }
}
