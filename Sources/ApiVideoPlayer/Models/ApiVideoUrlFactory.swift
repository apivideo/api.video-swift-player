import Foundation
class ApiVideoUrlFactory {
    private let videoOptions: VideoOptions
    private let taskExecutor: TasksExecutorProtocol.Type
    weak var delegate: ApiVideoUrlFactoryDelegate?
    private var xTokenSession: String?

    init(videoOptions: VideoOptions, taskExecutor: TasksExecutorProtocol.Type = TasksExecutor.self) {
        self.videoOptions = videoOptions
        self.taskExecutor = taskExecutor
    }

    /// Get the URL to read from api.video HLS
    func getHlsUrl(completion: @escaping (String) -> Void) {
        getTokenSession(url: videoOptions.hlsManifestUrl) { url in
            completion(url)
        }
    }

    /// Get the URL to read fro; api.video MP4
    func getMp4Url(completion: @escaping (String) -> Void) {
        getTokenSession(url: videoOptions.mp4Url) { url in
            completion(url)
        }
    }

    func getThumbnail(completion: @escaping (String) -> Void) {
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
                    delegate?.didError(PlayerError.urlError("Couldn't set up url from this videoId"))
                    return
                }
                RequestsBuilder.getSessionToken(taskExecutor: taskExecutor, url: url, completion: { sessionToken in
                    self.xTokenSession = sessionToken.sessionToken
                    tempUrl.appendTokenSession(token: sessionToken.sessionToken)
                    completion(tempUrl)
                }, didError: { error in
                    self.delegate?.didError(PlayerError.sessionTokenError(error.localizedDescription))
                })
            }
        } else {
            // do success with no token session, the video should be public
            completion(url)
        }
    }
}

public protocol ApiVideoUrlFactoryDelegate: AnyObject {
    func didError(_ error: Error)
}

extension String {
    mutating func appendTokenSession(token: String) {
        self.append("?avh=\(token)")
    }
}
