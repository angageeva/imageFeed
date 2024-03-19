import UIKit
import os.log

class imagesListViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBOutlet private var tableView: UITableView!
    
    let photosName: [String] = Array(0..<20).map{ "\($0)" }
    let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "ImageFeed")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 8, right: 0)
    }
}
