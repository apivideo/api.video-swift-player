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
            if let xTokenSession = xTokenSession {
                // do success with uri and xTokenSession
                completion("\(url)&avh=\(xTokenSession)")
            } else {
                guard let path = URL(string: videoOptions.sessionTokenUrl) else {
                    delegate?.didError(PlayerError.urlError("Couldn't set up url from this videoId"))
                    return
                }
                let request = RequestsBuilder().getSessionToken(path: path)
                let session = RequestsBuilder().buildUrlSession()
                self.taskExecutor.execute(session: session, request: request) { data, error in
                    if let data = data {
                        do {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            let token: TokenSession? = try decoder.decode(TokenSession.self, from: data)
                            if let token = token {
                                self.xTokenSession = token.sessionToken
                                completion("\(url)?avh=\(self.xTokenSession ?? token.sessionToken)")
                            } else {
                                self.delegate?
                                    .didError(
                                        PlayerError
                                            .urlError("An error occured while decode json, session_token is nil")
                                    )
                            }

                        } catch {
                            self.delegate?.didError(PlayerError.urlError(error.localizedDescription))
                            return
                        }
                    } else {
                        if let error = error {
                            self.delegate?.didError(PlayerError.urlError(error.localizedDescription))
                        } else {
                            self.delegate?
                                .didError(PlayerError.sessionTokenError("Request error, no valid session token"))
                        }
                    }
                }
            }
        } else {
            // do success with no token session, the video should be public
            completion(url)
        }
    }
}

protocol ApiVideoUrlFactoryDelegate: AnyObject {
    func didError(_ error: Error)
}
