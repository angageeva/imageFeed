@testable import imageFeed
import XCTest
import Foundation

//MARK: - Tests

final class ImagesListTests: XCTestCase {
    func testFetchPhotosNextPage() throws {
        //given
        let service = ImagesListServiceModelStub()
        let presenter = ImagesListViewPresenter(imagesListService: service)
        
        //then
        presenter.viewDidLoad()
        
        //when
        XCTAssertEqual(service.photos.count, 1)
    }
    
    func testViewDidLoadCalled() throws {
        //given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenterSpy()

        viewController.presenter = presenter
        presenter.view = viewController
        
        //then
        viewController.viewDidLoad()
        
        //when
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPhotosCount() throws {
        //given
        let service = ImagesListServiceModelStub()
        let presenter = ImagesListViewPresenter(imagesListService: service)
        
        //then
        presenter.viewDidLoad()
        
        //when
        XCTAssertEqual(presenter.photosCount(), 1)
    }
    
    func testGetFormattedDate() throws {
        //given
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        let formattedDate = formatter.string(from: Date())

        let service = ImagesListServiceModelStub()
        let presenter = ImagesListViewPresenter(imagesListService: service)
        
        //when
        XCTAssertEqual(presenter.getFormattedDate(), formattedDate)
    }
    
    func testNewPhotos() throws {
        //given
        let service = ImagesListServiceModelStub()
        let presenter = ImagesListViewPresenter(imagesListService: service)
        
        //then
        service.fetchPhotosNextPage() // Add a photo to the service
        let newPhotos = presenter.newPhotos()
        
        //when
        XCTAssertEqual(newPhotos.count, 1)
        XCTAssertEqual(newPhotos[0].id, service.photos[0].id)
    }
    
    func testPhotoByIndex() throws {
        //given
        let service = ImagesListServiceModelStub()
        let presenter = ImagesListViewPresenter(imagesListService: service)
        
        //then
        service.fetchPhotosNextPage() // Add a photo to the service
        let index = 0
        let photoByIndex = presenter.photoByIndex(index: index)
        
        //when
        XCTAssertEqual(photoByIndex.id, service.photos[index].id)
    }
    
    func testNewPhotosIndexPaths() throws {
        //given
        let viewController = ImagesListViewControllerSpy()
        let service = ImagesListServiceModelStub()
        let presenter = ImagesListViewPresenter(imagesListService: service)

        viewController.presenter = presenter
        presenter.view = viewController
        
        //then
        service.fetchPhotosNextPage() // Add a photo to the service
        let indexPaths = [IndexPath(row: 0, section: 0)]
        
        //when
        XCTAssertEqual(presenter.newPhotosIndexPaths(), indexPaths)
    }
    
    func testChangeLike() {
        //given
        let service = ImagesListServiceModelStub()
        let presenter = ImagesListViewPresenter(imagesListService: service)
        
        //then
        service.fetchPhotosNextPage() // Add a photo to the service
        presenter.changeLike(photoId: "1", isLiked: true) { _ in }
        
        //when
        XCTAssertEqual(service.photos[0].isLiked, false)
    }
    
    func testAddNotificationObserver() {
        //given
        let viewController = ImagesListViewControllerSpy()
        let service = ImagesListServiceModelStub()
        let presenter = ImagesListViewPresenter(imagesListService: service)

        viewController.presenter = presenter
        presenter.view = viewController
        
        //then
        presenter.addNotificationObserver()
        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: self,
            userInfo: [:]
        )
        
        //when
        XCTAssertTrue(viewController.updateTableCalled)
    }
}

//MARK: - Stub classes

final class ImagesListServiceModelStub: ImagesListServiceProtocol {
    var photos: [Photo] = []

    func fetchPhotosNextPage() {
        photos.append(
            Photo(
                id: "1",
                size: CGSize(width: 100, height: 100),
                createdAt: Date(),
                welcomeDescription: "test",
                thumbImageURL: "test",
                fullImageURL: "test",
                isLiked: true
            )
        )
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void?, Error>) -> Void) {
        photos[0].isLiked = !isLike
    }
}

//MARK: - Spy classes

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListViewPresenterProtocol?
    
    var shownPhotosCount = 0
    var updateTableCalled = false
    
    func viewDidLoad() {
        presenter?.viewDidLoad()
    }
    
    func updateTableViewAnimated() {
        updateTableCalled = true
    }
}

final class ImagesListPresenterSpy: ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var viewDidLoadCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func addNotificationObserver() {}
    func fetchPhotosNextPage() {}
    func photosCount() -> Int { return 1 }
    func getFormattedDate() -> String { return "" }
    func newPhotos() -> [Photo] { return [] }
    func newPhotosIndexPaths() -> [IndexPath] {return [] }
    func changeLike(photoId: String, isLiked: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {}
    
    func photoByIndex(index: Int) -> Photo {
        return Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: "test",
            thumbImageURL: "test",
            fullImageURL: "test",
            isLiked: true
        )
    }
}
