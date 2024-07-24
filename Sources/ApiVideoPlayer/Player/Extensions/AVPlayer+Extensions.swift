import AVFoundation
import Foundation

extension AVPlayer {
    var isPlaying: Bool {
        rate != 0 && error == nil
    }

    var videoSize: CGSize {
        guard let size = self.currentItem?.presentationSize else {
            return .zero
        }
        return size
    }

    /// Replaces the player's current item with the HLS of the provided video options.
    /// For private videos, this method will fetch a token session before playing the video and is therefore
    /// asynchronous.
    ///
    /// - Parameters:
    ///   - videoOptions: the video to play
    ///   - didError: the error callback. Only useful for private videos.
    public func replaceCurrentItem(withHls videoOptions: VideoOptions?, didError: @escaping (Error) -> Void = { _ in
    }) {
        guard let videoOptions = videoOptions else {
            self.replaceCurrentItem(with: nil)
            return
        }
        let factory = ApiVideoPlayerItemFactory(videoOptions: videoOptions)
        let delegate = ApiVideoPlayerItemFactoryDelegateImpl(didError: didError)
        factory.delegate = delegate
        factory.getHlsPlayerItem { item in
            self.replaceCurrentItem(with: item)
        }
    }

    /// Replaces the player's current item with the MP4 of the provided video options.
    /// For private videos, this method will fetch a token session before playing the video and is therefore
    /// asynchronous.
    ///
    /// - Parameters:
    ///   - videoOptions: the video to play
    ///   - didError: the error callback. Only useful for private videos.
    public func replaceCurrentItem(withMp4 videoOptions: VideoOptions?, didError: @escaping (Error) -> Void = { _ in
    }) {
        guard let videoOptions = videoOptions else {
            self.replaceCurrentItem(with: nil)
            return
        }
        let factory = ApiVideoPlayerItemFactory(videoOptions: videoOptions)
        let delegate = ApiVideoPlayerItemFactoryDelegateImpl(didError: didError)
        factory.delegate = delegate
        factory.getMp4PlayerItem { item in
            self.replaceCurrentItem(with: item)
        }
    }
}

class ApiVideoPlayerItemFactoryDelegateImpl: ApiVideoPlayerItemFactoryDelegate {
    let didError: (Error) -> Void

    init(didError: @escaping (Error) -> Void) {
        self.didError = didError
    }

    func didError(_ error: Error) {
        print("error : \(error)")
    }
}
