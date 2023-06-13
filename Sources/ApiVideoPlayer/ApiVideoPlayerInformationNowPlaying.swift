import Foundation
import MediaPlayer

protocol InformationNowPlaying {
    var nowPlayingData: NowPlayingData? { get set }
    func pause(currentTime: CMTime)
    func play(currentTime: CMTime)
    func updateCurrentTime(currentTime: CMTime)
    func updatePlaybackRate(rate: Float)
}

class ApiVideoPlayerInformationNowPlaying: InformationNowPlaying {
    private var infos = [String: Any]()
    private let taskExecutor: TasksExecutorProtocol.Type

    init(taskExecutor: TasksExecutorProtocol.Type) {
        self.taskExecutor = taskExecutor
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

            infos[MPNowPlayingInfoPropertyPlaybackRate] = nowPlayingData.playbackRate
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

    func updateCurrentTime(currentTime: CMTime) {
        self.overrideInformations(
            for: MPNowPlayingInfoPropertyElapsedPlaybackTime,
            value: currentTime.seconds
        )
    }

    func updatePlaybackRate(rate: Float) {
        self.overrideInformations(
            for: MPNowPlayingInfoPropertyPlaybackRate,
            value: rate
        )
    }

    func pause(currentTime: CMTime) {
        if #available(iOS 13.0, *) {
            MPNowPlayingInfoCenter.default().playbackState = .paused
        }
        self.overrideInformations(for: MPNowPlayingInfoPropertyElapsedPlaybackTime, value: currentTime.seconds)
    }

    func play(currentTime: CMTime) {
        if #available(iOS 13.0, *) {
            MPNowPlayingInfoCenter.default().playbackState = .playing
        }
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
