import UIKit

final class ImagesListViewController: UIViewController {
    let showSingleImageSegueIdentifier = "ShowSingleImage" //private? but extension is located in the other file
    let imageFeedLog = ImageFeedLog()
    let photoNames: [String] = Array(0..<20).map{ "\($0)" }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBOutlet private var tableView: UITableView!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            let image = UIImage(named: photoNames[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 8, right: 0)
    }
}
