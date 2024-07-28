import UIKit

// MARK: - SplashViewController

final class SplashViewController: UIViewController {
    
    // MARK: - Properties
    
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    private let showAuthenticationScreenSegueIdentifier = "showAuthenticationScreenSegueIdentifier"
    
    // MARK: - Public methods
    
    
    // MARK: - Lifecycle methods
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if oAuth2TokenStorage.token != nil {
            switchToBarController()
        } else {
            performSegue(withIdentifier: "showAuthenticationScreenSegueIdentifier", sender: nil)
        }
    }
    
    // MARK: -  Private methods
    
    private func switchToBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")

        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate() {
        switchToBarController()
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
           }
    }
}
