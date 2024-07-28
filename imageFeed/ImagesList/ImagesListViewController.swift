import UIKit

// MARK: - ImagesListViewController

final class ImagesListViewController: UIViewController {
    
    // MARK: - Properties
    
    let showSingleImageSegueIdentifier = "ShowSingleImage"
    let imageFeedLog = ImageFeedLog()
    let photoNames: [String] = Array(0..<20).map{ "\($0)" }
    
    private let topInset: CGFloat = 12
    private let bottomInset: CGFloat = 8
    private let leftInset: CGFloat = 0
    private let rightInset: CGFloat = 0

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
    }

    // MARK: - Public methods

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
}
