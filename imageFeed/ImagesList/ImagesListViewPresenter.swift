import Foundation

//MARK: - ImagesListViewPresenterProtocol

public protocol ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }

    func viewDidLoad()
    func addNotificationObserver()
    func fetchPhotosNextPage()
    func photosCount() -> Int
    func getFormattedDate() -> String
    func newPhotos() -> [Photo]
    func photoByIndex(index: Int) -> Photo
    func newPhotosIndexPaths() -> [IndexPath]
    func changeLike(photoId: String, isLiked: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
}

//MARK: - ImagesListViewPresenter

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    
    
    //MARK: - Public properties

    weak var view: ImagesListViewControllerProtocol?
    
    var photos: [Photo] = []
    
    private let imagesListService: ImagesListServiceProtocol
    private let photoDateFormat = "dd MMMM yyyy"
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = photoDateFormat
        return formatter
    }()
    
    init (imagesListService: ImagesListServiceProtocol) {
        self.imagesListService = imagesListService
    }
    
    //MARK: - LifeCycle

    func viewDidLoad() {
        addNotificationObserver()
        fetchPhotosNextPage()
    }
    
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    //MARK: - Public Methods
    func addNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            
            view?.updateTableViewAnimated()
        }
    }
    
    func newPhotos() -> [Photo] {
        imagesListService.photos
    }
    
    func photoByIndex(index: Int) -> Photo {
        newPhotos()[index]
    }
    
    func photosCount() -> Int {
        imagesListService.photos.count
    }
    
    func getFormattedDate() -> String {
        dateFormatter.string(from: Date())
    }
    
    func newPhotosIndexPaths() -> [IndexPath] {
        guard let oldCount = view?.shownPhotosCount else { return [] }
        let newCount = photosCount()
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        
        return indexPaths
    }
    
    func changeLike(photoId: String, isLiked: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        imagesListService.changeLike(photoId: photoId, isLike: isLiked) { [weak self] result in
            guard self != nil else { return }

            switch result {
            case .success:
                completion(.success(()))
            case.failure(let error):
                print("[ImagesListViewPresenter -> changeLike]: Error changing like: \(error)")
                completion(.failure(error))
            }
        }
    }
}
