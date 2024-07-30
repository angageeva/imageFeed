import Foundation

struct UserResult: Decodable {
    let profileImage: ProfileImage
    
    struct ProfileImage: Decodable {
        let small: String
    }
}

final class ProfileImageService {
    
    enum ProfileImageServiceError: Error {
        case invalidToken
        case invalidRequest
        case noData
    }
    
    private init() {}
    
    static let shared = ProfileImageService()
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private let oAuthTokenStorage = OAuth2TokenStorage()
    
    private var task: URLSessionTask?
    
    private (set) var avatarURL: String?
    
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
        
        let urlSessionTask = URLSession.shared.objectTask(for: profileImageRequest) { (result: Result<UserResult, Error>) in
            switch result {
            case .success(let profileImageResponse):
                let smallProfileImage = profileImageResponse.profileImage.small
                
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
        
//        let urlSessionTask = URLSession.shared.dataTask(with: profileImageRequest) { data, response, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            guard let data = data else {
//                completion(.failure(ProfileImageServiceError.noData))
//                return
//            }
//
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//            do {
//                let profileImageResponse = try decoder.decode(UserResult.self, from: data)
//                let smallProfileImage = profileImageResponse.profileImage.small
//
//                self.avatarURL = smallProfileImage
//
//                completion(.success(smallProfileImage))
//
//                DispatchQueue.main.async {
//                    NotificationCenter.default                                    //не уверена, что должно быть так "В методе fetchProfileImageURL сразу после вызова completion добавьте публикацию нотификации:"
//                        .post(
//                            name: ProfileImageService.didChangeNotification,
//                            object: self,
//                            userInfo: ["URL": smallProfileImage])
//                }
//            } catch {
//                completion(.failure(error))
//            }
//
//            self.task = nil
//        }
        self.task = urlSessionTask
        urlSessionTask.resume()
    }
    
    private func buildProfileImageRequest(username: String, token: String) -> URLRequest? {
        let url = Constants.defaultBaseURL.appendingPathComponent("/users/\(username)")
        var request = URLRequest(url: url)

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }

}
