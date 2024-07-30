import Foundation

struct ProfileResult: Decodable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}


final class ProfileService {
    
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
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        if let task = self.task {
            task .cancel()
        }
        
        guard let profileDataRequest = buildProfileDataRequest(token: token) else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let urlSessionTask = URLSession.shared.dataTask(with: profileDataRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(ProfileServiceError.noData))
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let profileResponse = try decoder.decode(ProfileResult.self, from: data)
                let profile = self.buildProfile(profileResponse: profileResponse)
                self.profile = profile
                completion(.success(profile))
            } catch {
                completion(.failure(error))
            }

            self.task = nil
        }
        self.task = urlSessionTask
        urlSessionTask.resume()
    }

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
            bio: profileResponse.bio)
    }
}
