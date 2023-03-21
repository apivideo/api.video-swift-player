import ApiVideoPlayerAnalytics
import AVFoundation
import AVKit
import Foundation

/// The ApiVideoPlayerController class is a wrapper around ``AVPlayer``.
public class ApiVideoPlayerController: NSObject {
    private let avPlayer = AVPlayer(playerItem: nil)
    private var analytics: PlayerAnalytics?
    private var timeObserver: Any?
    private var isFirstPlay = true
    private var isSeeking = false
    private let taskExecutor: TasksExecutorProtocol.Type
    private let multicastDelegate = ApiVideoPlayerControllerMulticastDelegate()
    private var playerItemFactory: ApiVideoPlayerItemFactory?

    #if !os(macOS)
    public convenience init(
        videoOptions: VideoOptions?,
        playerLayer: AVPlayerLayer,
        delegates: [PlayerDelegate] = [],
        autoplay: Bool = false
    ) {
        self.init(
            videoOptions: videoOptions,
            delegates: delegates,
            autoplay: autoplay
        )
        playerLayer.player = self.avPlayer
    }
    #endif

    public init(
        videoOptions: VideoOptions?,
        delegates: [PlayerDelegate] = [],
        autoplay: Bool = false,
        taskExecutor: TasksExecutorProtocol.Type = TasksExecutor.self
    ) {
        multicastDelegate.addDelegates(delegates)
        self.taskExecutor = taskExecutor
        super.init()
        defer {
            self.videoOptions = videoOptions
        }

        self.autoplay = autoplay
        self.avPlayer.addObserver(
            self,
            forKeyPath: "timeControlStatus",
            options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old],
            context: nil
        )
        self.avPlayer.addObserver(
            self,
            forKeyPath: "currentItem.presentationSize",
            options: NSKeyValueObservingOptions.new,
            context: nil
        )
    }

    private func getVideoUrl(videoOptions: VideoOptions) -> String {
        let privateToken: String? = nil
        var baseUrl = ""
        if videoOptions.videoType == .vod {
            baseUrl = "https://cdn.api.video/vod/"
        } else {
            baseUrl = "https://live.api.video/"
        }
        var url: String!

        if let privateToken = privateToken {
            url = baseUrl + "\(videoOptions.videoId)/token/\(privateToken)/player.json"
        } else {
            url = baseUrl + "\(videoOptions.videoId)/player.json"
        }
        return url
    }

    private func retrySetUpPlayerUrlWithMp4() {
        self.playerItemFactory?.getMp4PlayerItem { currentItem in
            self.preparePlayer(playerItem: currentItem)
        }
    }

    func addDelegates(delegates: [PlayerDelegate]) {
        multicastDelegate.addDelegates(delegates)
    }

    func addDelegate(delegate: PlayerDelegate) {
        multicastDelegate.addDelegate(delegate)
    }

    func removeDelegate(delegate: PlayerDelegate) {
        multicastDelegate.removeDelegate(delegate)
    }

    func removeDelegates(delegates: [PlayerDelegate]) {
        multicastDelegate.removeDelegates(delegates)
    }

    private func resetPlayer(with playerItem: AVPlayerItem? = nil) {
        if let currentItem = avPlayer.currentItem {
            currentItem.removeObserver(self, forKeyPath: "status", context: nil)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: currentItem)
        }

        avPlayer.replaceCurrentItem(with: playerItem)
    }

    private func preparePlayer(playerItem: AVPlayerItem) {
        self.multicastDelegate.didPrepare()
        resetPlayer(with: playerItem)
        playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }

    private func notifyError(error: Error) {
        self.multicastDelegate.didError(error)
    }

    public func addOutput(output: AVPlayerItemOutput) {
        guard let item = avPlayer.currentItem else {
            return
        }
        item.add(output)
    }

    public func removeOutput(output: AVPlayerItemOutput) {
        guard let item = avPlayer.currentItem else {
            return
        }
        item.remove(output)
    }

    public func addTimerObserver(callback: @escaping () -> Void) -> Any {
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        return avPlayer.addPeriodicTimeObserver(
            forInterval: interval,
            queue: DispatchQueue.main,
            using: { _ in
                callback()
            }
        )
    }

    public func removeTimeObserver(_ observer: Any) {
        avPlayer.removeTimeObserver(observer)
    }

    private func setUpAnalytics(url: String) {
        do {
            let option = try Options(mediaUrl: url, metadata: [])
            self.analytics = PlayerAnalytics(options: option)
        } catch {
            print("error with the url")
        }
    }

    public var isLive: Bool {
        guard let currentItem = avPlayer.currentItem else {
            return false
        }
        return currentItem.duration.isIndefinite
    }

    public var isVod: Bool {
        guard let currentItem = avPlayer.currentItem else {
            return false
        }
        return !currentItem.duration.isIndefinite
    }

    public var isPlaying: Bool {
        self.avPlayer.isPlaying
    }

    public func play() {
        self.avPlayer.play()
    }

    private func seekImpl(to time: CMTime, completion: @escaping (Bool) -> Void) {
        let from = self.currentTime
        self.avPlayer.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { completed in
            self.analytics?
                .seek(
                    from: Float(CMTimeGetSeconds(from)),
                    to: Float(CMTimeGetSeconds(self.currentTime))
                ) { result in
                    switch result {
                    case .success: break
                    case let .failure(error): print("analytics error on seek event: \(error)")
                    }
                }
            completion(completed)
        }
    }

    public func replay() {
        self.seekImpl(to: CMTime.zero, completion: { _ in
            self.play()
            self.multicastDelegate.didReplay()
        })

    }

    public func pause() {
        self.avPlayer.pause()
    }

    public func pauseBeforeSeek() {
        self.isSeeking = true
        self.avPlayer.pause()
    }

    public func seek(offset: CMTime, completion: @escaping (Bool) -> Void = { _ in
    }) {
        self.seek(to: self.currentTime + offset, completion: completion)
    }

    public func seek(to: CMTime, completion: @escaping (Bool) -> Void = { _ in
    }) {
        let from = self.currentTime
        self.seekImpl(to: to, completion: { completed in
            completion(completed)
            self.multicastDelegate.didSeek(from, self.currentTime)
        })
    }

    public var videoOptions: VideoOptions? {
        didSet {
            guard let videoOptions = videoOptions else {
                resetPlayer(with: nil)
                return
            }
            playerItemFactory = ApiVideoPlayerItemFactory(videoOptions: videoOptions, taskExecutor: taskExecutor)
            playerItemFactory?.delegate = self
            playerItemFactory?.getHlsPlayerItem { currentItem in
                self.preparePlayer(playerItem: currentItem)
            }
        }
    }

    public var isMuted: Bool {
        get {
            self.avPlayer.isMuted
        }
        set(newValue) {
            self.avPlayer.isMuted = newValue
            if newValue {
                self.multicastDelegate.didMute()
            } else {
                self.multicastDelegate.didUnMute()
            }
        }
    }

    public var isLooping = false
    public var autoplay = false

    public var volume: Float {
        get {
            self.avPlayer.volume
        }
        set(newVolume) {
            self.avPlayer.volume = newVolume
            self.multicastDelegate.didSetVolume(volume)
        }
    }

    /// Get the current video duration.
    /// If the video is live, the duration is the seekable duration.
    /// The duration is invalid if the video is not ready or not set.
    public var duration: CMTime {
        guard let currentItem = avPlayer.currentItem else {
            return CMTime.invalid
        }

        if isVod {
            return currentItem.asset.duration
        } else if isLive {
            guard let seekableDuration = currentItem.seekableTimeRanges.last?.timeRangeValue.end.seconds else {
                return CMTime.invalid
            }
            return CMTime(seconds: seekableDuration, preferredTimescale: 1_000)
        } else {
            print("duration is not available")
            return CMTime.invalid
        }
    }

    /// Get the current video position.
    /// The position is invalid if the video is not ready or not set.
    public var currentTime: CMTime {
        self.avPlayer.currentTime()
    }

    public var isAtEnd: Bool {
        self.duration.roundedSeconds == self.currentTime.roundedSeconds
    }

    public var videoSize: CGSize {
        self.avPlayer.videoSize
    }

    public var hasSubtitles: Bool {
        !subtitleLocales.isEmpty
    }

    public var subtitleLocales: [Locale] {
        var locales: [Locale] = []
        if let playerItem = avPlayer.currentItem,
           let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) {
            for option in group.options where option.displayName != "CC" {
                if let locale = option.locale {
                    locales.append(locale)
                }
            }
        }
        return locales
    }

    public var currentSubtitleLocale: Locale? {
        if let playerItem = avPlayer.currentItem,
           let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible),
           let selectedOption = playerItem.currentMediaSelection.selectedMediaOption(in: group) {
            return selectedOption.locale
        }
        return nil
    }

    public func setCurrentSubtitleLocale(locale: Locale) {
        if let playerItem = avPlayer.currentItem,
           let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) {
            let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
            if let option = options.first {
                playerItem.select(option, in: group)
            }
        }
    }

    public func hideSubtitle() {
        guard let playerItem = avPlayer.currentItem else {
            return
        }
        if let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) {
            playerItem.select(nil, in: group)
        }
    }

    #if !os(macOS)
    public func goToFullScreen(viewController: UIViewController) {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = self.avPlayer
        viewController.present(playerViewController, animated: true) {
            self.play()
        }
    }
    #endif

    @objc
    func playerDidFinishPlaying() {
        if self.isLooping {
            self.replay()
            self.multicastDelegate.didLoop()
        }
        self.analytics?.end { result in
            switch result {
            case .success: break
            case let .failure(error): print("analytics error on ended event: \(error)")
            }
        }
        self.multicastDelegate.didEnd()
    }

    private func doFallbackOnFailed() {
        if self.avPlayer.currentItem?.status == .failed {
            guard let url = (avPlayer.currentItem?.asset as? AVURLAsset)?.url else {
                return
            }
            if url.absoluteString.contains(".mp4") {
                print("Failed to read MP4 video")
                self.notifyError(error: PlayerError.videoError("Failed to read video"))
                return
            } else {
                print("Failed to read HLS video, retrying with mp4")
                self.retrySetUpPlayerUrlWithMp4()
            }
        }
    }

    private func doReadyToPlay() {
        if self.avPlayer.currentItem?.status == .readyToPlay {
            self.multicastDelegate.didReady()
            if self.autoplay {
                self.play()
            }
        }
    }

    private func doPauseAction() {
        if round(self.currentTime.seconds) >= round(self.duration.seconds) {
            return
        }

        if self.isSeeking {
            return
        }

        self.analytics?.pause { result in
            switch result {
            case .success: break
            case let .failure(error): print("analytics error on pause event: \(error)")
            }
        }
        self.multicastDelegate.didPause()
    }

    private func doPlayAction() {
        if self.isSeeking {
            self.isSeeking = false
            return
        }
        if self.isFirstPlay {
            self.isFirstPlay = false
            self.analytics?.play { result in
                switch result {
                case .success: return
                case let .failure(error): print("analytics error on play event: \(error)")
                }
            }
        } else {
            self.analytics?.resume { result in
                switch result {
                case .success: return
                case let .failure(error): print("analytics error on resume event: \(error)")
                }
            }
        }
        self.multicastDelegate.didPlay()
    }

    private func doTimeControlStatus() {
        let status = self.avPlayer.timeControlStatus
        switch status {
        case .paused:
            // Paused mode
            self.doPauseAction()

        case .waitingToPlayAtSpecifiedRate:
            // Resumed
            break

        case .playing:
            // Video Ended
            self.doPlayAction()
        @unknown default:
            break
        }
    }

    override public func observeValue(
        forKeyPath keyPath: String?,
        of _: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context _: UnsafeMutableRawPointer?
    ) {
        if keyPath == "status" {
            self.doFallbackOnFailed()
            self.doReadyToPlay()
        }
        if keyPath == "timeControlStatus" {
            guard let change = change else {
                return
            }
            guard let newValue = change[.newKey] as? Int else {
                return
            }
            guard let oldValue = change[.oldKey] as? Int else {
                return
            }
            if oldValue != newValue {
                self.doTimeControlStatus()
            }
        }
        if keyPath == "currentItem.presentationSize" {
            guard let change = change else {
                return
            }
            guard let newSize = change[.newKey] as? CGSize else {
                return
            }
            self.multicastDelegate.didVideoSizeChanged(newSize)
        }
    }

    deinit {
        avPlayer.removeObserver(self, forKeyPath: "currentItem.presentationSize", context: nil)
        avPlayer.removeObserver(self, forKeyPath: "timeControlStatus", context: nil)
        avPlayer.currentItem?.removeObserver(self, forKeyPath: "status", context: nil)
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: ApiVideoPlayerItemFactoryDelegate

extension ApiVideoPlayerController: ApiVideoPlayerItemFactoryDelegate {
    public func didError(_ error: Error) {
        self.multicastDelegate.didError(error)
    }
}

enum PlayerError: Error {
    case videoError(String)
    case urlError(String)
    case videoIdError(String)
    case sessionTokenError(String)
}
