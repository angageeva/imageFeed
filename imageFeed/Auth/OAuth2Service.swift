import Foundation

//MARK: - OAuth2Service

enum OAuth2Error: Error {
    case noData
    case invalidRequest
}

final class OAuth2Service {
    // MARK: - Properties

    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Public methods
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.fetchOAuthToken(code: code, completion: completion)
            }
            return
        }
        
        guard lastCode != code else {
            completion(.failure(OAuth2Error.invalidRequest))
            return
        }
        task?.cancel()
        self.lastCode = code
        
        guard let oAuthTokenRequest = buildOAuthTokenRequest(code: code) else {
            completion(.failure(OAuth2Error.invalidRequest))
            return
        }
        let urlSessionTask = urlSession.objectTask(for: oAuthTokenRequest) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let tokenResponseBody):
                let accessToken = tokenResponseBody.accessToken

                completion(.success(accessToken))

                self?.task = nil
                self?.lastCode = nil
            case .failure(let error):
                print("[OAuth2Service -> fetchOAuthToken]: \(error)")
                completion(.failure(error))
            }
        }
        self.task = urlSessionTask

        urlSessionTask.resume()
    }
    
    // MARK: - Private methods
    
    private init() {}
    
    private func buildOAuthTokenRequest(code: String) -> URLRequest? {
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token")!

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        guard let url = urlComponents.url else {
            assertionFailure("Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        return request
    }
}
