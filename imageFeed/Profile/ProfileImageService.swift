import Foundation

// MARK: ProfileImageService

struct UserResult: Decodable {
    let profileImage: ProfileImage
    
    struct ProfileImage: Decodable {
        let small: String
    }
}

final class ProfileImageService {
    
    // MARK: - Properties
    
    enum ProfileImageServiceError: Error {
        case invalidToken
        case invalidRequest
        case noData
    }
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private let oAuthTokenStorage = OAuth2TokenStorage()

    private var task: URLSessionTask?
    
    private (set) var avatarURL: String?
    
    private init() {}
    
    // MARK: - Public methods
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        if let task = self.task {
            task .cancel()
        }
        
        guard let token = oAuthTokenStorage.token else {
            completion(.failure(ProfileImageServiceError.invalidToken))
            return
        }
        
        guard let profileImageRequest = buildProfileImageRequest(username: username, token: token) else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        let urlSessionTask = URLSession.shared.objectTask(for: profileImageRequest) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let profileImageResponse):
                let smallProfileImage = self.smallProfilePngImage(profileImageResponse.profileImage.small)
                
                self.avatarURL = smallProfileImage
                
                completion(.success(smallProfileImage))
                
                DispatchQueue.main.async {
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": smallProfileImage])
                }
                self.task = nil
            case .failure(let error):
                print("[ProfileImageService -> fetchProfileImageURL]: \(error)")
                completion(.failure(error))
            }
        }
        self.task = urlSessionTask

        urlSessionTask.resume()
    }
    
    func cleanProfileImage() {
        avatarURL = nil
    }
    
    // MARK: - Private methods
    
    private func buildProfileImageRequest(username: String, token: String) -> URLRequest? {
        let url = Constants.defaultBaseURL.appendingPathComponent("/users/\(username)")
        var request = URLRequest(url: url)

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }
    
    private func smallProfilePngImage(_ profieImageUrl: String) -> String {
        // we need 'fm' parameter for fetching Unsplash png image to make RoundCornerImageProcessor work correctly
        (profieImageUrl + "&fm=png")
    }
}
