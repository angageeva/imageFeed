import UIKit

final class imagesListViewController: UIViewController {
    let imageFeedLog = ImageFeedLog()
    let photoNames: [String] = Array(0..<20).map{ "\($0)" }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 8, right: 0)
    }
}
