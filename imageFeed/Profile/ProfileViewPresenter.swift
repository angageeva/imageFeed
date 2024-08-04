import Foundation

public protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    var profileService: ProfileService? { get set }
    func viewDidLoad()
    func loadAvatar()
    func currentProfile() -> Profile?
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var profileService: ProfileService?
    
    private let profileLogoutService = ProfileLogoutService.shared
    
    func viewDidLoad() {
        addNotificationCenterObserver()
        loadAvatar()
    }
    
    func loadAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        view?.updateAvatar(imageURL: url)
    }
    
    func currentProfile() -> Profile? {
        guard let profile = profileService?.profile else { return nil }

        return profile
    }
    
    private func addNotificationCenterObserver() {
        NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            
            loadAvatar()
        }
    }
}
