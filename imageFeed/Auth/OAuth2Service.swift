import Foundation

//MARK: - OAuth2Service

final class OAuth2Service {
    // MARK: - Properties
    
    static let shared = OAuth2Service()
    
    // MARK: - Public methods
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let oAuthTokenRequest = buildOAuthTokenRequest(code: code) else {
            print("Can't build the request!")
            return
        }
        let urlSessionTask = URLSession.shared.data(for: oAuthTokenRequest, completion: completion)

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
            print("Can't form the url!")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        return request
    }
}
