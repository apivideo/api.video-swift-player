import ApiVideoPlayerAnalytics
import AVFoundation
import AVKit
import Foundation

@available(iOS 14.0, *)
public class PlayerController: NSObject {
    private var events = [PlayerEvents]()
    private let avPlayer = AVPlayer(playerItem: nil)
    private let offSubtitleLanguage = SubtitleLanguage(language: "Off", code: nil)
    private var analytics: PlayerAnalytics?
    private let videoType: VideoType
    private let videoId: String!
    private var playerManifest: PlayerManifest!
    private var timeObserver: Any?
    private var isFirstPlay = true

    #if !os(macOS)
        convenience init(videoId: String, videoType: VideoType, events: PlayerEvents? = nil, view: UIView, playerLayer: AVPlayerLayer) throws {
            try self.init(videoId: videoId, videoType: videoType, events: events)
            playerLayer.player = avPlayer
            view.layer.addSublayer(playerLayer)
        }
    #endif

    init(videoId: String, videoType: VideoType, events: PlayerEvents?) throws {
        self.videoId = videoId
        self.videoType = videoType

        super.init()
        if let events = events {
            addEvents(events: events)
        }

        getPlayerJSON(videoType: videoType) { error in
            if let error = error {
                self.notifyError(error: error)
            }
        }
    }

    private func getVideoUrl(videoType: VideoType, privateToken: String? = nil) -> String {
        var baseUrl = ""
        if videoType == .vod {
            baseUrl = "https://cdn.api.video/vod/"
        } else {
            baseUrl = "https://live.api.video/"
        }
        var url: String!

        if let privateToken = privateToken {
            url = baseUrl + "\(videoId!)/token/\(privateToken)/player.json"
        } else {
            url = baseUrl + "\(videoId!)/player.json"
        }

        return url
    }

    private func getPlayerJSON(videoType: VideoType, completion: @escaping (Error?) -> Void) {
        let request = RequestsBuilder().getPlayerData(path: getVideoUrl(videoType: videoType))
        let session = RequestsBuilder().buildUrlSession()
        TasksExecutor.execute(session: session, request: request) { data, error in
            if let data = data {
                do {
                    self.playerManifest = try JSONDecoder().decode(PlayerManifest.self, from: data)
                    self.setUpAnalytics(url: self.playerManifest.video.src)
                    try self.setUpPlayer(self.playerManifest.video.src)
                    completion(nil)
                } catch {
                    completion(error)
                    return
                }
            } else {
                completion(error)
            }
        }
    }

    private func retrySetUpPlayerUrlWithMp4() {
        guard let mp4 = playerManifest.video.mp4 else {
            print("Error there is no mp4")
            notifyError(error: PlayerError.mp4Error("There is no mp4"))
            return
        }
        do {
            try setUpPlayer(mp4)
        } catch {
            notifyError(error: error)
        }
    }

    private func setUpPlayer(_ url: String) throws {
        if let url = URL(string: url) {
            let item = AVPlayerItem(url: url)
            avPlayer.currentItem?.removeObserver(self, forKeyPath: "status", context: nil)
            avPlayer.replaceCurrentItem(with: item)
            avPlayer.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
            item.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: item)
        } else {
            throw PlayerError.urlError("bad url")
        }
    }

    private func notifyError(error: Error) {
        for events in events {
            events.didError?(error)
        }
    }

    public func addEvents(events: PlayerEvents) {
        self.events.append(events)
    }

    public func removeEvents(events: PlayerEvents) {
        self.events.removeAll { $0 === events }
    }

    public func setTimerObserver(callback: @escaping (() -> Void)) {
        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { _ in
            callback()
        })
    }

    public func removeTimeObserver() {
        if let timeObserver = timeObserver {
            avPlayer.removeTimeObserver(timeObserver)
        }
    }

    private func setUpAnalytics(url: String) {
        do {
            let option = try Options(
                mediaUrl: url, metadata: []
            )
            analytics = PlayerAnalytics(options: option)
        } catch {
            print("error with the url")
        }
    }

    public func isPlaying() -> Bool {
        return avPlayer.isPlaying()
    }

    public func play() {
        avPlayer.play()
    }

    public func replay() {
        analytics?.seek(from: Float(CMTimeGetSeconds(currentTime)), to: Float(CMTimeGetSeconds(CMTime.zero))) { result in
            switch result {
            case .success: break
            case let .failure(error):
                print("analytics error on seek event: \(error)")
            }
        }
        avPlayer.seek(to: CMTime.zero)
        play()
        analytics?.resume { result in
            switch result {
            case .success: break
            case let .failure(error):
                print("analytics error on resume event: \(error)")
            }
        }
        for events in events {
            events.didRePlay?()
        }
    }

    public func pause() {
        avPlayer.pause()
    }

    public func seek(time: Double) {
        let currentTimeInSeconds = CMTimeGetSeconds(currentTime).advanced(by: time)
        let seekTime = CMTime(value: CMTimeValue(currentTimeInSeconds), timescale: 1)
        seek(seekTime: seekTime, currentTimeInSeconds: currentTimeInSeconds)
    }

    public func seek(to: Double) {
        let seekTime = CMTime(seconds: to, preferredTimescale: 1)
        seek(seekTime: seekTime, currentTimeInSeconds: CMTimeGetSeconds(seekTime))
    }

    private func seek(seekTime: CMTime, currentTimeInSeconds: Float64) {
        let cts = currentTimeInSeconds
        avPlayer.seek(to: seekTime)
        analytics?.seek(from: Float(CMTimeGetSeconds(currentTime)), to: Float(CMTimeGetSeconds(seekTime))) { result in
            switch result {
            case let .success(data):
                print("player analytics seek : \(data)")
            case let .failure(error):
                print("player analytics seek : \(error)")
            }
        }

        for events in events {
            events.didSeekTime?(currentTime.seconds, max(0.0, cts))
        }
    }

    public var isMuted: Bool {
        get {
            return avPlayer.isMuted
        }
        set(newValue) {
            avPlayer.isMuted = newValue
            if newValue {
                for events in events {
                    events.didMute?()
                }
            } else {
                for events in events {
                    events.didUnMute?()
                }
            }
        }
    }

    public var isLooping: Bool = false

    public var volume: Float {
        get { return avPlayer.volume }
        set(newVolume) {
            avPlayer.volume = newVolume
            for events in events {
                events.didSetVolume?(volume)
            }
        }
    }

    public var duration: CMTime {
        return avPlayer.currentItem!.asset.duration
    }

    public var currentTime: CMTime {
        return avPlayer.currentTime()
    }

    var subtitles: [SubtitleLanguage] {
        var subtitles: [SubtitleLanguage] = [offSubtitleLanguage]
        if let playerItem = avPlayer.currentItem,
           let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible)
        {
            for option in group.options where option.displayName != "CC" {
                subtitles.append(SubtitleLanguage(language: option.displayName, code: option.extendedLanguageTag))
            }
        }
        return subtitles
    }

    var currentSubtitle: SubtitleLanguage {
        get {
            if let playerItem = avPlayer.currentItem,
               let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible),
               let selectedOption = playerItem.currentMediaSelection.selectedMediaOption(in: group),
               let locale = selectedOption.locale
            {
                return SubtitleLanguage(language: locale.identifier, code: locale.languageCode)
            }
            return offSubtitleLanguage
        }
        set(newSubtitle) {
            if let playerItem = avPlayer.currentItem,
               let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible)
            {
                if newSubtitle.code == nil {
                    hideSubtitle()
                } else {
                    let locale = Locale(identifier: newSubtitle.language)
                    let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
                    if let option = options.first {
                        avPlayer.currentItem!.select(option, in: group)
                    }
                }
            }
        }
    }

    #if !os(macOS)
        public func goToFullScreen(viewController: UIViewController) {
            let playerViewController = AVPlayerViewController()
            playerViewController.player = avPlayer
            viewController.present(playerViewController, animated: true) {
                self.play()
            }
        }
    #endif

    func hideSubtitle() {
        if let group = avPlayer.currentItem!.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) {
            avPlayer.currentItem!.select(nil, in: group)
        }
    }

    @objc func playerDidFinishPlaying() {
        if isLooping {
            replay()
            for events in events {
                events.didLoop?()
            }
        }
        analytics?.end { result in
            switch result {
            case .success: break
            case let .failure(error):
                print("analytics error on ended event: \(error)")
            }
        }
        for events in events {
            events.didEnd?()
        }
    }

    override public func observeValue(forKeyPath keyPath: String?, of _: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if avPlayer.currentItem?.status == .failed {
                guard let url = (avPlayer.currentItem?.asset as? AVURLAsset)?.url else {
                    return
                }
                if url.absoluteString.contains(".mp4") {
                    print("Error with video mp4")
                    notifyError(error: PlayerError.mp4Error("Tryed mp4 but failed"))
                    return
                } else {
                    print("Error with video url, trying with mp4")
                    retrySetUpPlayerUrlWithMp4()
                }
            }
        }
        if keyPath == "rate" {
            let status = avPlayer.timeControlStatus
            switch status {
            case .paused:
                // Paused mode
                analytics?.pause { result in
                    switch result {
                    case .success: break
                    case let .failure(error):
                        print("analytics error on pause event: \(error)")
                    }
                }
                for events in events {
                    events.didPause?()
                }
            case .waitingToPlayAtSpecifiedRate:
                // Resumed
                if isFirstPlay {
                    isFirstPlay = false
                    analytics?.play { result in
                        switch result {
                        case .success: break
                        case let .failure(error):
                            print("analytics error on play event: \(error)")
                        }
                    }
                } else {
                    analytics?.resume { result in
                        switch result {
                        case .success: break
                        case let .failure(error):
                            print("analytics error on resume event: \(error)")
                        }
                    }
                }
                for events in events {
                    events.didPlay?()
                }
            case .playing:
                // Video Ended
                break

            @unknown default:
                break
            }
        }
    }

    deinit {
        avPlayer.removeObserver(self, forKeyPath: "rate", context: nil)
        avPlayer.currentItem?.removeObserver(self, forKeyPath: "status", context: nil)
        NotificationCenter.default.removeObserver(self)
    }
}

extension AVPlayer {
    @available(iOS 10.0, *)
    func isPlaying() -> Bool {
        return (rate != 0 && error == nil)
    }
}

enum PlayerError: Error {
    case mp4Error(String)
    case urlError(String)
}
