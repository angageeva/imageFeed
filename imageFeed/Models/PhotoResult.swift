import Foundation

//MARK: - PhotoResult

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let likes: Int
    let description: String
    let likedByUser: Bool
    let urls: UrlsResult
}

struct UrlsResult: Decodable {
    let thumb: URL
    let full: URL
}

