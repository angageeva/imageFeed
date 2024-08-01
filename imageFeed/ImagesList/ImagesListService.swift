import Foundation
import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let fullImageURL: String
    var isLiked: Bool
}

final class ImagesListService {
    static let shared = ImagesListService()
    
    private let photoDateFormat = "dd MMMM yyyy"
    private let oAuthTokenStorage = OAuth2TokenStorage()
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private var task: URLSessionTask?
    private var lastLoadedPage = 1
    private (set) var photos: [Photo] = []
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = photoDateFormat
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    func fetchPhotosNextPage() {
        if self.task != nil {
            print("[ImagesListService -> fetchPhotosNextPage]: Downloading is already in process.")
            return
        }
        
        guard let token = oAuthTokenStorage.token else {
            print("[ImagesListService -> fetchPhotosNextPage]: Invalid token.")
            return
        }
        
        guard let photoRequest = buildPhotoRequest(token: token) else {
            print("[ImagesListService -> fetchPhotosNextPage]: Invalid request.")
            return
        }
        
        lastLoadedPage += 1
        
        // return to code [weak self], not working without
        let urlSessionTask = URLSession.shared.objectTask(for: photoRequest) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else {
                return }
            DispatchQueue.main.async {
                switch result {
                case .success(let photoResult):
                    let photoGroup = photoResult.map {
                        Photo( id: $0.id,
                               size: CGSize(width: $0.width, height: $0.height),
                               createdAt: self.dateFormatter.date(from: $0.createdAt),
                               welcomeDescription: $0.description,
                               thumbImageURL: $0.urls.thumb.absoluteString,
                               fullImageURL: $0.urls.full.absoluteString,
                               isLiked: $0.likedByUser)
                    }
                    
                    self.photos.append(contentsOf: photoGroup)
                    
                    
                    NotificationCenter.default
                        .post(
                            name: ImagesListService.didChangeNotification,
                            object: self)
                    
                    
                    self.task = nil
                case .failure(let error):
                    print("[ImagesListService -> fetchPhotosNextPage]: Error loading photos: \(error).")
                }
            }
        }
        self.task = urlSessionTask
        
        urlSessionTask.resume()
    }
    
    
    
    //let nextPage = (lastLoadedPage ?? 0) + 1
    //Добавить свойство task: URLSessionTask? (сохраняем в нём результат urlSession.objectTask), и если task != nil, то сетевой запрос в прогрессе.
    // Так как читать массив photos мы будем из main
    
    private func buildPhotoRequest(token: String) -> URLRequest? {
        let photosUrl = Constants.defaultBaseURL.appendingPathComponent("/photos")
        var components = URLComponents(url: photosUrl, resolvingAgainstBaseURL: true)
        components?.queryItems = [URLQueryItem(name: "page", value: String(lastLoadedPage))]

        guard let url = components?.url else {
            assertionFailure("Failed to create URL with query parameters")
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void?, Error>) -> Void) {
        guard let token = oAuthTokenStorage.token else {
            print("[ImagesListService]: Inavlid token.")
            return
        }
        
        let url = Constants.defaultBaseURL.appendingPathComponent("/photos/\(photoId)/like")
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let urlSessionTask = URLSession.shared.data(for: request) { [weak self] result in
            guard let self = self else { return }
            //скореее всего должен быть main.assync
            //в учебнике предлагают делать копию всего элемента и заменять
            switch result {
            case .success:
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    self.photos[index].isLiked = !isLike
                    completion(.success(nil))
                }
                print(self.photos)
            case .failure(let error):
                completion(.failure(error))
            }
        }
        urlSessionTask.resume()
    }
    
    func cleanPhotos() {
        photos = []
    }
}


