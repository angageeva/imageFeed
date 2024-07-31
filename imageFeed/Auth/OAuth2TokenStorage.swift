import Foundation
import SwiftKeychainWrapper

// MARK: - OAuth2TokenStorage

final class OAuth2TokenStorage {
    
    // MARK: - Properties
    
    private let keychainStorage = KeychainWrapper.standard
    
     enum Keys: String {
        case token
    }
    
    var token: String? {
        get {
            keychainStorage.string(forKey: Keys.token.rawValue)
        }
        set {
            if let newValue = newValue {
                keychainStorage.set(newValue, forKey: Keys.token.rawValue)
            } else {
                keychainStorage.removeObject(forKey: Keys.token.rawValue)
            }
        }
    }
}
