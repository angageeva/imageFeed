import UIKit
import ProgressHUD

//MARK: - UIBlockingProgressHUD

final class UIBlockingProgressHUD {
    
    // MARK: - Properties
    
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    // MARK: - Public methods
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
