import AVFoundation
import Foundation

/// Factory to create the ``AVPlayerItem`` to read api.video items from ``VideoOptions``.
class ApiVideoPlayerItemFactory {
    weak var delegate: ApiVideoPlayerItemFactoryDelegate?
    private let urlFactory: ApiVideoUrlFactory!

    /// Initializes the ``AVPlayerItem`` factory.
    ///
    /// - Parameters:
    ///   - videoOptions: The video options
    ///   - taskExecutor: The executor for the calls to the private session endpoint. Only for test purpose. Default is
    /// ``TasksExecutor``.
    init(videoOptions: VideoOptions, taskExecutor: TasksExecutorProtocol.Type = TasksExecutor.self) {
        self.urlFactory = ApiVideoUrlFactory(videoOptions: videoOptions, taskExecutor: taskExecutor)
        self.urlFactory.delegate = self
    }

    /// Gets the ``AVPlayerItem`` of the api.video MP4
    /// - Parameter completion: The completion handler
    func getHlsPlayerItem(completion: @escaping (AVPlayerItem) -> Void) {
        urlFactory.getHlsUrl { url in
            guard let item = self.createPlayerItem(url: url) else {
                return
            }
            completion(item)
        }
    }

    /// Gets the ``AVPlayerItem`` of the api.video MP4
    /// - Parameter completion: The completion handler
    func getMp4PlayerItem(completion: @escaping (AVPlayerItem) -> Void) {
        urlFactory.getMp4Url { url in
            guard let item = self.createPlayerItem(url: url) else {
                return
            }
            completion(item)
        }
    }

    /// Gets the URL of the api.video thumbnail
    /// - Parameter completion: The completion handler
    func getThumbnailUrl(completion: @escaping (String) -> Void) {
        urlFactory.getThumbnailUrl { url in
            completion(url)
        }
    }

    private func createPlayerItem(url: String) -> AVPlayerItem? {
        guard let path = URL(string: url) else {
            delegate?.didError(PlayerError.urlError("Invalid URL"))
            return nil
        }
        return AVPlayerItem(url: path)
    }

}

// MARK: ApiVideoUrlFactoryDelegate

extension ApiVideoPlayerItemFactory: ApiVideoUrlFactoryDelegate {
    func didError(_ error: Error) {
        self.delegate?.didError(error)
    }

}

public protocol ApiVideoPlayerItemFactoryDelegate: AnyObject {
    func didError(_ error: Error)
}
