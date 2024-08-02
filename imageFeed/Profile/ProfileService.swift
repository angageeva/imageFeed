import Foundation

// MARK: ProfileResult

struct ProfileResult: Decodable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
}

final class ProfileService {
    
    // MARK: - Properties
    
    enum ProfileServiceError: Error {
        case invalidURL
        case invalidRequest
        case noData
        case noProfile
    }
    
    private init() {}
    
    static let shared = ProfileService()
    
    private let oAuthTokenStorage = OAuth2TokenStorage()
    
    private var task: URLSessionTask?
    
    private(set) var profile: Profile?
    
    // MARK: - Public methods
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        if let task = self.task {
            task.cancel()
        }
        
        guard let profileDataRequest = buildProfileDataRequest(token: token) else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let urlSessionTask = URLSession.shared.objectTask(for: profileDataRequest) { [weak self](result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let profileResult):
                let profile = self.buildProfile(profileResponse: profileResult)

                self.profile = profile
                completion(.success(profile))

                self.task = nil
            case .failure(let error):
                print("[ProfileService -> fetchProfile]: \(error)")
                completion(.failure(error))
            }
        }
        self.task = urlSessionTask

        urlSessionTask.resume()
    }
    
    // MARK: - Public methods
    
    func cleanProfile() {
        profile = nil
    }
    
    // MARK: - Private methods

    private func buildProfileDataRequest(token: String) -> URLRequest? {
        let url = Constants.defaultBaseURL.appendingPathComponent("/me")
        var request = URLRequest(url: url)

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }
    
    private func buildProfile(profileResponse: ProfileResult) -> Profile {
        let name = "\(profileResponse.firstName) \(profileResponse.lastName ?? "")".trimmingCharacters(in: .whitespaces)
        let loginName = "@\(profileResponse.username)"

        return Profile(
            username: profileResponse.username,
            name: name,
            loginName: loginName,
            bio: profileResponse.bio
        )
    }
}
