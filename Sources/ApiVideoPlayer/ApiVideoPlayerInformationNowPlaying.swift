import Foundation
import MediaPlayer

protocol InformationNowPlaying {
    func update(metadata: [String: Any]?)
    func pause(currentTime: CMTime, currentRate: Float)
    func play(currentTime: CMTime, currentRate: Float)
    func overrideInformations(for key: String, value: Any)
    func clearMPNowPlayingInfoCenter()
}

class ApiVideoPlayerInformationNowPlaying: InformationNowPlaying {
    private var infos = [String: Any]()
    private let taskExecutor: TasksExecutorProtocol.Type

    init(taskExecutor: TasksExecutorProtocol.Type) {
        self.taskExecutor = taskExecutor
    }

    func update(metadata: [String: Any]?) {
        if let title = metadata?["title"] {
            infos[MPMediaItemPropertyTitle] = title
        }
        if let duration = metadata?["duration"] as? CMTime {
            infos[MPMediaItemPropertyPlaybackDuration] = duration.seconds
        }
        if let currentTime = metadata?["currentTime"] as? CMTime {
            infos[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime.seconds
        }
        if let isLive = metadata?["isLive"] as? Bool {
            infos[MPNowPlayingInfoPropertyIsLiveStream] = isLive
        }
        infos[MPNowPlayingInfoPropertyPlaybackRate] = 1.0

        #if !os(macOS)
        if let imageStr = metadata?["thumbnailUrl"] as? String {
            if let url = URL(string: imageStr) {
                updateRemoteArtwork(url: url)
            }
        }
        #endif

        MPNowPlayingInfoCenter.default().nowPlayingInfo = infos
    }

    func pause(currentTime: CMTime, currentRate: Float) {
        infos[MPNowPlayingInfoPropertyPlaybackRate] = currentRate
        MPNowPlayingInfoCenter.default().playbackState = .paused
        self.overrideInformations(for: MPNowPlayingInfoPropertyElapsedPlaybackTime, value: currentTime.seconds)
    }

    func play(currentTime: CMTime, currentRate: Float) {
        infos[MPNowPlayingInfoPropertyPlaybackRate] = currentRate
        MPNowPlayingInfoCenter.default().playbackState = .playing
        self.overrideInformations(for: MPNowPlayingInfoPropertyElapsedPlaybackTime, value: currentTime.seconds)
    }

    func overrideInformations(for key: String, value: Any) {
        infos[key] = value
        MPNowPlayingInfoCenter.default().nowPlayingInfo = infos
    }

    func clearMPNowPlayingInfoCenter() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    #if !os(macOS)
    private func getArtwork(image: UIImage) -> MPMediaItemArtwork {
        return MPMediaItemArtwork(boundsSize: image.size) { _ in image }
    }

    private func updateRemoteArtwork(url: URL) {
        RequestsBuilder.getThumbnail(taskExecutor: self.taskExecutor, url: url, completion: { image in
            let artwork = self.getArtwork(image: image)
            self.overrideInformations(for: MPMediaItemPropertyArtwork, value: artwork)
        }, didError: { error in
            print("Error on artwork : \(error.localizedDescription)")
        })
    }
    #endif
}
