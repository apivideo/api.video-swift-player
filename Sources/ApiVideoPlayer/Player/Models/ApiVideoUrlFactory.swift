import Foundation

/// Factory to create the URL to read api.video items from ``VideoOptions``.
class ApiVideoUrlFactory {
    private let videoOptions: VideoOptions
    private let taskExecutor: TasksExecutorProtocol.Type
    weak var delegate: ApiVideoUrlFactoryDelegate?
    private var xTokenSession: String?

    /// Initializes the URL factory.
    ///
    /// - Parameters:
    ///   - videoOptions: The video options
    ///   - taskExecutor: The executor for the calls to the private session endpoint. Only for test purpose. Default is
    /// ``TasksExecutor``.
    init(videoOptions: VideoOptions, taskExecutor: TasksExecutorProtocol.Type = TasksExecutor.self) {
        self.videoOptions = videoOptions
        self.taskExecutor = taskExecutor
    }

    /// Gets the URL of the api.video HLS
    /// - Parameter completion: The completion handler
    func getHlsUrl(completion: @escaping (String) -> Void) {
        getTokenSession(url: videoOptions.hlsManifestUrl) { url in
            completion(url)
        }
    }

    /// Gets the URL of the api.video MP4
    /// - Parameter completion: The completion handler
    func getMp4Url(completion: @escaping (String) -> Void) {
        getTokenSession(url: videoOptions.mp4Url) { url in
            completion(url)
        }
    }

    /// Gets the URL of the api.video thumbnail
    /// - Parameter completion: The completion handler
    func getThumbnailUrl(completion: @escaping (String) -> Void) {
        getTokenSession(url: videoOptions.thumbnailUrl) { url in
            completion(url)
        }
    }

    private func getTokenSession(url: String, completion: @escaping (String) -> Void) {
        if videoOptions.token != nil {
            // check if xTokenSession already exists
            var tempUrl = url
            if let xTokenSession = xTokenSession {
                // do success with uri and xTokenSession
                tempUrl.appendTokenSession(token: xTokenSession)
                completion(tempUrl)
            } else {
                guard let url = URL(string: videoOptions.sessionTokenUrl) else {
                    delegate?.didError(PlayerError.invalidUrl(url))
                    return
                }
                RequestsBuilder.getSessionToken(taskExecutor: taskExecutor, url: url) { result in
                    switch result {
                    case let .success(sessionToken):
                        self.xTokenSession = sessionToken.sessionToken
                        tempUrl.appendTokenSession(token: sessionToken.sessionToken)
                        completion(tempUrl)

                    case let .failure(error):
                        self.delegate?.didError(error)
                    }
                }
            }
        } else {
            // do success with no token session, the video should be public
            completion(url)
        }
    }
}

/// Delegate to handle errors from the ``ApiVideoUrlFactory``.
public protocol ApiVideoUrlFactoryDelegate: AnyObject {
    func didError(_ error: Error)
}

extension String {
    mutating func appendTokenSession(token: String) {
        self.append("?avh=\(token)")
    }
}
