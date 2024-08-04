import UIKit

// MARK: - ImagesListViewController

public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListViewPresenterProtocol? {get set}
    var shownPhotosCount: Int { get }

    func updateTableViewAnimated()
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    
    // MARK: - Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let showSingleImageSegueIdentifier = "ShowSingleImage"
    let imageFeedLog = ImageFeedLog()
    let photoNames: [String] = Array(0..<20).map{ "\($0)" }

    var shownPhotosCount = 0
    var presenter: ImagesListViewPresenterProtocol?
    
    private let topInset: CGFloat = 12
    private let bottomInset: CGFloat = 8
    private let leftInset: CGFloat = 0
    private let rightInset: CGFloat = 0
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter?.view = self
        presenter?.viewDidLoad()
    }
    
    // MARK: - Public methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == showSingleImageSegueIdentifier,
            let viewController = segue.destination as? SingleImageViewController,
            let indexPath = sender as? IndexPath,
            let selectedPhoto = presenter?.photoByIndex(index: indexPath.row)
        else {
            assertionFailure("Invalid segue destination")
            super.prepare(for: segue, sender: sender)

            return
        }

        viewController.photo = selectedPhoto
    }
    
    func updateTableViewAnimated() {
        guard let viewPresenter = presenter else { return }
        let indexPaths = viewPresenter.newPhotosIndexPaths()

        if indexPaths.count > 0 {
            self.shownPhotosCount = viewPresenter.photosCount()

            self.tableView.performBatchUpdates {
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    func photos() -> [Photo] {
        guard let photos = presenter?.newPhotos() else { return [] }

        return photos
    }
}
