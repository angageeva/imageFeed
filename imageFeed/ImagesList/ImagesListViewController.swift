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

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()

    func getFormattedDate() -> String {
        dateFormatter.string(from: Date())
    }

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
        guard
            segue.identifier == showSingleImageSegueIdentifier,
            let viewController = segue.destination as? SingleImageViewController,
            let indexPath = sender as? IndexPath
        else {
            assertionFailure("Invalid segue destination")
            super.prepare(for: segue, sender: sender)
            return
        }
        let image = UIImage(named: photoNames[indexPath.row])

        viewController.image = image
    }
}
