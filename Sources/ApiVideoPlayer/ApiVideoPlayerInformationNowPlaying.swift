import Foundation
import MediaPlayer

protocol InformationNowPlaying {
    func update(metadata: [String: Any]?)
    func pause(currentTime: CMTime)
    func play(currentTime: CMTime)
    func overrideInformations(for key: String, value: Any)
}

#if !os(macOS)
class ApiVideoPlayerInformationNowPlaying: InformationNowPlaying {
    private var infos = [String: Any]()
    private let taskExecutor: TasksExecutorProtocol.Type

    init(taskExecutor: TasksExecutorProtocol.Type) {
        self.taskExecutor = taskExecutor
    }

    func update(metadata: [String: Any]?) {
        infos[MPMediaItemPropertyTitle] = metadata?["title"] ?? ""
        if let duration = metadata?["duration"] as? CMTime {
            print("duration info center : \(duration)")
            infos[MPMediaItemPropertyPlaybackDuration] = duration.seconds
        }
        if let currentTime = metadata?["currentTime"] as? CMTime {
            infos[MPNowPlayingInfoPropertyElapsedPlaybackTime] = round(currentTime.seconds)
        }
        if let isLive = metadata?["isLive"] as? Bool {
            infos[MPNowPlayingInfoPropertyIsLiveStream] = isLive
        }
        infos[MPNowPlayingInfoPropertyPlaybackRate] = 1.0

        if let imageStr = metadata?["thumbnailUrl"] as? String {
            if let url = URL(string: imageStr) {
                updateRemoteImage(url: url)
            }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = infos
    }

    func pause(currentTime: CMTime) {
        infos[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
        MPNowPlayingInfoCenter.default().playbackState = .paused
        self.overrideInformations(for: MPNowPlayingInfoPropertyElapsedPlaybackTime, value: currentTime.seconds)
    }

    func play(currentTime: CMTime) {
        infos[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        MPNowPlayingInfoCenter.default().playbackState = .playing
        self.overrideInformations(for: MPNowPlayingInfoPropertyElapsedPlaybackTime, value: currentTime.seconds)
    }

    func overrideInformations(for key: String, value: Any) {
        infos[key] = value
        print("infos : \(infos.values)")
        MPNowPlayingInfoCenter.default().nowPlayingInfo = infos
    }

    private func getArtwork(image: UIImage) -> MPMediaItemArtwork {
        return MPMediaItemArtwork(boundsSize: image.size) { _ in image }
    }

    private func updateRemoteImage(url: URL) {
        RequestsBuilder.getThumbnailImage(taskExecutor: self.taskExecutor, url: url, completion: { data in
            guard let uiImage = UIImage(data: data) else {
                return
            }
            let artwork = self.getArtwork(image: uiImage)
            self.overrideInformations(for: MPMediaItemPropertyArtwork, value: artwork)
        }, didError: { _ in

        })
    }

}
#endif
