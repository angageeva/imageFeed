import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case decodeError(Error)
}

extension URLSession {
    
    private static let sharedDecoder: JSONDecoder = {
           let decoder = JSONDecoder()
           decoder.keyDecodingStrategy = .convertFromSnakeCase
           return decoder
       }()
    
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    let httpStatusCodeError = NetworkError.httpStatusCode(statusCode)
                    print("[dataTask]: Network Error - \(httpStatusCodeError)")

                    fulfillCompletionOnTheMainThread(.failure(httpStatusCodeError))
                }
            } else if let error = error {
                let urlRequestError = NetworkError.urlRequestError(error)
                print("[dataTask]: Network Error - \(urlRequestError)")

                fulfillCompletionOnTheMainThread(.failure(urlRequestError))
            } else {
                let urlSessionError = NetworkError.urlSessionError
                print("[dataTask]: Network Error - \(urlSessionError)")

                fulfillCompletionOnTheMainThread(.failure(urlSessionError))
            }
        })
        
        return task
    }
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = URLSession.sharedDecoder

        let task = data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)

                    completion(.success(decodedObject))
                } catch {
                    let decodeError = NetworkError.decodeError(error)
                    print("[objectTask]: Decode Error - \(decodeError)")

                    completion(.failure(decodeError))
                }
            case .failure:
                let urlSessionError = NetworkError.urlSessionError
                print("[objectTask]: Network Error - \(urlSessionError)")

                completion(.failure(urlSessionError))
            }
        }
        return task
    }
}
