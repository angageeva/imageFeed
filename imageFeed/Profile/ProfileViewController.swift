import UIKit
import Kingfisher

// MARK: ProfileViewController

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }

    func updateAvatar(imageURL: URL)
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    
    // MARK: - Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    var presenter: ProfileViewPresenterProtocol?
    
    private let oAuthTokenStorage = OAuth2TokenStorage()
    private let imageView = UIImageView()
    private let profileService = ProfileService.shared
    private let profileLogoutService = ProfileLogoutService.shared

    private let nameLabel = UILabel()
    private let nickLabel = UILabel()
    private let descriptionLabel = UILabel()

    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .ypBlack

        presenter?.profileService = profileService
        presenter?.viewDidLoad()

        addProfileImage()
        addExitButton()
        addLabels()
        
        guard let profile = presenter?.currentProfile() else { return }
        updateProfileDetails(profile: profile)
    }
    
    // MARK: - Public methods
    
    func updateAvatar(imageURL: URL) {
        let processor = RoundCornerImageProcessor(cornerRadius: 35)

        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: imageURL,
                              placeholder: UIImage(named: "placeholder.png"),
                              options: [
                                .processor(processor),
                                       ]) { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                print("[ProfileViewController -> updateAvatar]: Error loading image: \(error)")
            }
        }
    }
    
    // MARK: - Private methods
    
    private func addProfileImage() {
        imageView.translatesAutoresizingMaskIntoConstraints = false

        //adding subview
        view.addSubview(imageView)
        
        //adding constraints
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
    }
    
    private func addLabels() {
        addNameLabel()
        addNickLabel()
        addDescriptionLabel()
    }
    
    private func addNameLabel() {
        // editing nameLabel
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.textColor = .ypWhite
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
    }
    
    private func addNickLabel() {
        // editing nickLabel
        nickLabel.font = UIFont.systemFont(ofSize: 13)
        nickLabel.textColor = .ypGray
        
        nickLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nickLabel)
        
        nickLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        nickLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        nickLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
    }

    private func addDescriptionLabel() {
        // editing descriptionLabel
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.numberOfLines = 0

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: nickLabel.bottomAnchor, constant: 8).isActive = true
    }
 
    // function for adding exit button
    private func addExitButton() {
        let button = UIButton.systemButton(
            with: UIImage(named: "exit_button")!,
            target: nil,
            action: nil
        )
        button.tintColor = .ypRed
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "logoutButton"

        view.addSubview(button)

        button.widthAnchor.constraint(equalToConstant: 20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 22).isActive = true
        button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -26).isActive = true
        
        button.addTarget(
            self,
            action: #selector(exitButtonHandler),
            for: .touchUpInside
        )
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        descriptionLabel.text = profile.bio ?? ""
        nickLabel.text = profile.loginName
    }
    
    @objc private func exitButtonHandler() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        let actionLogout = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.profileLogoutService.logout()

            if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                window.rootViewController = SplashViewController()
            }
        }
        alert.addAction(actionLogout)
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}
