import UIKit
import ProgressHUD

// MARK: - AuthViewController

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate()
}

final class AuthViewController: UIViewController {

    // MARK: - Properties
    
    weak var delegate: AuthViewControllerDelegate?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private let oAuthTokenStorage = OAuth2TokenStorage()
    private let showWebViewIdentifier = "ShowWebView"
    private let oAuth2Service = OAuth2Service.shared

    @IBOutlet private weak var logButton: UIButton!

    // MARK: - Lifecyclemethods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNeedsStatusBarAppearanceUpdate()

        settingLogButton()
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewIdentifier {
            guard let webViewController = segue.destination as? WebViewController else {
                print("[AuthViewController -> prepare]: Error in webViewController segue destination setup")
                return
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
    
    private func showAlert() {
        let alertController = UIAlertController(title: "Что-то пошло не так(", message: "Не удалось войти в систему", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ок", style: .default, handler: nil)

        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}

extension AuthViewController: WebViewControllerDelegate {
    func webViewViewController(_ vc: WebViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        
        oAuth2Service.fetchOAuthToken(code: code) { [weak self] result in
            switch result {
            case .success(let accessToken):
                self?.oAuthTokenStorage.token = accessToken
                
                DispatchQueue.main.async {
                    self?.dismiss(animated: true) {
                        UIBlockingProgressHUD.dismiss()
                        self?.delegate?.didAuthenticate()
                    }
                }
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()

                self?.showAlert()
                print("[AuthViewController -> webViewViewController]: Error from UNSPLASH: \(error)")
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewController) {
        dismiss(animated: true)
    }
}
