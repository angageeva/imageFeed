import UIKit
import SwiftKeychainWrapper

// MARK: - SplashViewController

final class SplashViewController: UIViewController {
    
    // MARK: - Properties
    
    private let oAuthTokenStorage = OAuth2TokenStorage()
    private let showAuthenticationScreenSegueIdentifier = "showAuthenticationScreenSegueIdentifier"
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Public methods
    
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        
        prepareSplashViewContent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oAuthTokenStorage.token {
            fetchProfile(token)
        } else {
            segueToAuthViewController()
        }
    }
    
    // MARK: -  Private methods
    
    private func prepareSplashViewContent() {
        view.backgroundColor = .ypBlack
        let logoImage = UIImage(named: "logo")
        let logoImageView = UIImageView(image: logoImage)
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(logoImageView)
        logoImageView.contentMode = .scaleAspectFit
        
        logoImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        logoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 75).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 77).isActive = true
    }
    
    private func switchToBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")

        window.rootViewController = tabBarController
    }
    
    private func segueToAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let authViewController = storyboard.instantiateViewController(identifier: "AuthViewController") as! AuthViewController
        authViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: authViewController)

        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate() {
        //vc.dismiss(animated: true) //added dc
        
        guard let token = oAuthTokenStorage.token else {
            return
        }
        
        fetchProfile(token)
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            //profileImageService.shared.fetch...
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                DispatchQueue.main.async {
                    self.switchToBarController()
                    self.fetchProfileImage(profile.username)
                }
            case .failure(let error):
                    print("Error of fetching the profile: \(error)")
                break
            }
        }
    }
    
    private func fetchProfileImage(_ username: String) {
        ProfileImageService.shared.fetchProfileImageURL(username: username) {_ in }
    }
}
