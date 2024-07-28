import UIKit

//MARK: - AuthViewController

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(accessToken: String)
}

final class AuthViewController: UIViewController {

    // MARK: - Properties

    private let showWebViewIdentifier = "ShowWebView"
    private let oAuth2Service = OAuth2Service.shared

    weak var delegate: AuthViewControllerDelegate?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet private weak var logButton: UIButton!
    
    // MARK: - Lifecyclemethods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingLogButton()
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewIdentifier {
            guard
                let webViewController = segue.destination as? WebViewController
            else {
                fatalError("Failed to prepare for \(showWebViewIdentifier)")
            }
            webViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private methods
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black (iOS)")
    }
    
    private func settingLogButton() {
        logButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
    }
}

extension AuthViewController: WebViewControllerDelegate {
    func webViewViewController(_ vc: WebViewController, didAuthenticateWithCode code: String) {
        oAuth2Service.fetchOAuthToken(code: code) { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let tokenResponse = try decoder.decode(OAuthTokenResponseBody.self, from: data)

                    self.dismiss(animated: true) {
                        self.delegate?.didAuthenticate(accessToken: tokenResponse.accessToken)
                    }
                } catch {
                    print("Failed to decode JSON: \(error)")
                }
            case .failure(let error):
                print("Error from UNSPLASH: \(error)")
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewController) {
        dismiss(animated: true)
    }
}
