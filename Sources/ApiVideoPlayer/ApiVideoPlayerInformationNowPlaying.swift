import Foundation
import MediaPlayer

protocol InformationNowPlaying {
    var nowPlayingData: NowPlayingData? { get set }
    var currentTime: CMTime? { get set }
    var playbackRate: Float? { get set }
    func pause(currentTime: CMTime, currentRate: Float)
    func play(currentTime: CMTime, currentRate: Float)
}

class ApiVideoPlayerInformationNowPlaying: InformationNowPlaying {
    private var infos = [String: Any]()
    private let taskExecutor: TasksExecutorProtocol.Type

    init(taskExecutor: TasksExecutorProtocol.Type) {
        self.taskExecutor = taskExecutor
    }

    var currentTime: CMTime? {
        didSet {
            guard let currentTime = currentTime else {
                return
            }
            self.overrideInformations(
                for: MPNowPlayingInfoPropertyElapsedPlaybackTime,
                value: currentTime.seconds
            )
        }
    }

    var playbackRate: Float? {
        didSet {
            guard let playbackRate = playbackRate else {
                return
            }
            self.overrideInformations(
                for: MPNowPlayingInfoPropertyPlaybackRate,
                value: playbackRate
            )
        }
    }

    var nowPlayingData: NowPlayingData? {
        didSet {
            guard let nowPlayingData = nowPlayingData else {
                MPNowPlayingInfoCenter.default().nowPlayingInfo = [:]
                return
            }
            if let title = nowPlayingData.title {
                infos[MPMediaItemPropertyTitle] = title
            }
            infos[MPMediaItemPropertyPlaybackDuration] = nowPlayingData.duration.seconds
            infos[MPNowPlayingInfoPropertyElapsedPlaybackTime] = nowPlayingData.currentTime.seconds
            infos[MPNowPlayingInfoPropertyIsLiveStream] = nowPlayingData.isLive

            infos[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
            #if !os(macOS)
            if let thumb = nowPlayingData.thumbnailUrl {
                if let url = URL(string: thumb) {
                    updateRemoteArtwork(url: url)
                }
            }
            #endif
            MPNowPlayingInfoCenter.default().nowPlayingInfo = infos
        }
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

    private func overrideInformations(for key: String, value: Any) {
        infos[key] = value
        MPNowPlayingInfoCenter.default().nowPlayingInfo = infos
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
