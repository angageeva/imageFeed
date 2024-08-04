@testable import imageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    func testViewDidLoadCalled() throws {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenterSpy()

        viewController.presenter = presenter
        presenter.view = viewController
        
        //then
        viewController.viewDidLoad()
        
        //when
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testAddNotificationCenterObserverCalled() throws {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenterSpy()

        viewController.presenter = presenter
        presenter.view = viewController
        
        //then
        viewController.viewDidLoad()
        
        //when
        XCTAssertTrue(presenter.addNotificationCenterObserverCalled)
    }
    
    func testCurrentProfile() throws {
        //given
        let presenter = ProfileViewPresenter()
        presenter.profileService = ProfileServiceStub.shared
        
        //then
        guard let currentProfile = presenter.currentProfile(),
              let sharedProfile = presenter.profileService?.profile
        else { return }
        
        //when
        XCTAssertEqual(currentProfile.username, sharedProfile.username)
        XCTAssertEqual(currentProfile.name, sharedProfile.name)
        XCTAssertEqual(currentProfile.loginName, sharedProfile.loginName)
        XCTAssertEqual(currentProfile.bio, sharedProfile.bio)
    }
    
    func testViewControllerCallsLoadAvatar() {
        //given
        let profilePresenter = ProfileViewPresenterSpy()
        let profileViewController = ProfileViewControllerSpy()
        profilePresenter.view = profileViewController
        profileViewController.presenter = profilePresenter
        
        //then
        profileViewController.viewDidLoad()
        
        //when
        XCTAssertTrue(profilePresenter.didCallLoadAvatar)
    }
}

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var profileService: imageFeed.ProfileService?
    
    var view: ProfileViewControllerProtocol?
    var didCallLoadAvatar = false
    var viewDidLoadCalled = false
    var addNotificationCenterObserverCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true

        addNotificationCenterObserver()
        loadAvatar()
    }
    
    func addNotificationCenterObserver() {
        addNotificationCenterObserverCalled = true
    }
    
    func loadAvatar() {
        didCallLoadAvatar = true
    }
    
    func currentProfile() -> Profile? { nil }
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: imageFeed.ProfileViewPresenterProtocol?
    
    func updateAvatar(imageURL: URL) {}
    
    func viewDidLoad() {
        presenter?.viewDidLoad()
    }
    
    func loadAvatar() {}
}

final class ProfileServiceStub: ProfileService {
    func profile() -> Profile {
        return Profile(
            username: "username",
            name: "name",
            loginName: "loginName",
            bio: "bio"
        )
    }
}
