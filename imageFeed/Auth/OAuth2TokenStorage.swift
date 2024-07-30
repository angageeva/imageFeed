import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let keychainStorage = KeychainWrapper.standard
    
    private enum Keys: String {
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
