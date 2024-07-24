import Foundation
#if !os(macOS)
import UIKit
#endif

/// Static methods to build the network requests.
enum RequestsBuilder {
    private static func setContentType(request: inout URLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    private static func buildUrlRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        setContentType(request: &request)
        request.httpMethod = "GET"
        return request
    }

    private static func buildUrlSession() -> URLSession {
        URLSession(configuration: URLSessionConfiguration.default)
    }

    static func getSessionToken(
        taskExecutor: TasksExecutorProtocol.Type,
        url: URL,
        completion: @escaping (Result<TokenSession, Error>) -> Void
    ) {
        let request = buildUrlRequest(url: url)
        let session = buildUrlSession()
        taskExecutor.execute(session: session, request: request) { result in
            switch result {
            case let .success(data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let token: TokenSession = try decoder.decode(TokenSession.self, from: data)
                    completion(.success(token))
                } catch {
                    completion(.failure(error))
                }

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    #if !os(macOS)
    static func getThumbnail(
        taskExecutor: TasksExecutorProtocol.Type,
        url: URL,
        completion: @escaping (UIImage) -> Void,
        didError: @escaping (Error) -> Void
    ) {
        let request = buildUrlRequest(url: url)
        let session = buildUrlSession()
        taskExecutor.execute(session: session, request: request) { result in
            switch result {
            case let .success(data):
                if let uiImage = UIImage(data: data) {
                    completion(uiImage)
                } else {
                    didError(PlayerError.thumbnailDecodeFailed(url))
                }

            case let .failure(error):
                didError(error)
            }
        }
    }
    #endif
}
