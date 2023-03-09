import AVFoundation
import Foundation
class ApiVideoPlayerItemFactory {
    weak var delegate: ApiVideoPlayerItemFactoryDelegate?
    private let urlFactory: ApiVideoUrlFactory!

    init(videoOptions: VideoOptions, taskExecutor: TasksExecutorProtocol.Type = TasksExecutor.self) {
        self.urlFactory = ApiVideoUrlFactory(videoOptions: videoOptions, taskExecutor: taskExecutor)
        self.urlFactory.delegate = self
    }

    func getHlsPlayerItem(completion: @escaping (AVPlayerItem) -> Void) {
        urlFactory.getHlsUrl { url in
            guard let item = self.createPlayerItem(url: url) else {
                return
            }
            completion(item)
        }
    }

    func getMp4PlayerItem(completion: @escaping (AVPlayerItem) -> Void) {
        urlFactory.getMp4Url { url in
            guard let item = self.createPlayerItem(url: url) else {
                return
            }
            completion(item)
        }
    }

    func getThumbnailPlayerItem(completion: @escaping (AVPlayerItem) -> Void) {
        urlFactory.getThumbnail { url in
            guard let item = self.createPlayerItem(url: url) else {
                return
            }
            completion(item)
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

protocol ApiVideoPlayerItemFactoryDelegate: AnyObject {
    func didError(_ error: Error)
}
