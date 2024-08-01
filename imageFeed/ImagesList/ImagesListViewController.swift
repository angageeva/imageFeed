import UIKit

// MARK: - ImagesListViewController

final class ImagesListViewController: UIViewController {
    
    // MARK: - Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let showSingleImageSegueIdentifier = "ShowSingleImage"
    let imageFeedLog = ImageFeedLog()
    let photoNames: [String] = Array(0..<20).map{ "\($0)" }
    let imagesListService = ImagesListService.shared
    
    var photos: [Photo] = []
    
    private let topInset: CGFloat = 12
    private let bottomInset: CGFloat = 8
    private let leftInset: CGFloat = 0
    private let rightInset: CGFloat = 0
    private let photoDateFormat = "dd MMMM yyyy"
    
    @IBOutlet var tableView: UITableView!
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = photoDateFormat
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    private var imagesListServiceObserver: NSObjectProtocol?
    
    func getFormattedDate() -> String {
        dateFormatter.string(from: Date())
    }
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                
                self.updateTableViewAnimated()
            }
        imagesListService.fetchPhotosNextPage()
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
        let selectedPhoto = photos[indexPath.row]
        
        viewController.photo = selectedPhoto
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
}
