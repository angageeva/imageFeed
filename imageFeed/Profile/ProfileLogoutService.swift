import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private let oAuthTokenStorage = OAuth2TokenStorage()
    private let profileImageService = ProfileImageService.shared
    private let imagesListService = ImagesListService.shared
    private let profileService = ProfileService.shared
    
    private init() { }
    
    func logout() {
        UIBlockingProgressHUD.show()
        
        cleanCookies()
        cleanToken()
        profileImageService.cleanProfileImage()
        imagesListService.cleanPhotos()
        profileService.cleanProfile()
        
        UIBlockingProgressHUD.dismiss()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanToken() {
        oAuthTokenStorage.token = nil
    }
}

