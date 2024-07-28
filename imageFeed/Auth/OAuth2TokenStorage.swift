import Foundation

final class OAuth2TokenStorage {
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case token
    }

    var token: String? {
        get {
            guard let token = userDefaults.string(forKey: Keys.token.rawValue) else {
                return nil
            }
            return token
        }
        set {
            userDefaults.set(newValue, forKey: Keys.token.rawValue)
        }
    }
}
