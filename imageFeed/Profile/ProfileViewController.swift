import UIKit
import Kingfisher

// MARK: ProfileViewController

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private let oAuthTokenStorage = OAuth2TokenStorage()
    private let imageView = UIImageView()
    private let profileService = ProfileService.shared
    
    private let nameLabel = UILabel()
    private let nickLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }

                self.updateAvatar()
            }
        updateAvatar()
        addProfileImage()
        addExitButton()
        addLabels()

        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
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

        view.addSubview(button)

        button.widthAnchor.constraint(equalToConstant: 20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 22).isActive = true
        button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -26).isActive = true
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        descriptionLabel.text = profile.bio ?? ""
        nickLabel.text = profile.loginName
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)

        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url,
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
}
