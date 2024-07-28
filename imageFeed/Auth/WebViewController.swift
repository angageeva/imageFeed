import UIKit
import WebKit

//MARK: - WebViewController

protocol WebViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewController)
}

final class WebViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak private var webView: WKWebView!
    @IBOutlet weak private var progressView: UIProgressView!
    
    weak var delegate: WebViewControllerDelegate?
    
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Lifecyclemethods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        webView.addObserver( //перенести во viewWillAppear и добавить отписку
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
        updateProgress()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAuthView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    // MARK: - Private methods
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewController.unsplashAuthorizeURLString) else {
            print("Can't initial the urlComponents!")
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            print("Can't form the url!")
            return
        }
        let request = URLRequest(url: url)

        webView.load(request)
        webView.navigationDelegate = self
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: {$0.name == "code"})
        {
            return codeItem.value
        } else {
            return nil
        }
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)

            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
