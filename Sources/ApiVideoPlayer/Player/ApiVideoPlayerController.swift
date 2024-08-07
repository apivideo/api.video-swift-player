import ApiVideoPlayerAnalytics
import AVFoundation
import AVKit
import Foundation
import MediaPlayer

/// The ApiVideoPlayerController class is a wrapper around ``AVPlayer``.
/// It is used internally of the ``ApiVideoPlayerView``.
/// It could be used directly if you want to use the player with a fully custom UI.
public class ApiVideoPlayerController: NSObject {
    internal let player = ApiVideoAnalyticsAVPlayer(playerItem: nil)
    private var timeObserver: Any?
    private var isFirstPlay = true
    private var isSeeking = false
    private let taskExecutor: TasksExecutorProtocol.Type
    private let multicastDelegate = ApiVideoPlayerControllerMulticastDelegate()
    private var playerItemFactory: ApiVideoPlayerItemFactory?
    private var storedSpeedRate: Float = 1.0
    private var infoNowPlaying: ApiVideoPlayerInformationNowPlaying

    #if !os(macOS)
    /// Creates a player controller to display the video in a ``AVPlayerLayer``.
    /// - Parameters:
    ///   - videoOptions: The video to play.
    ///   - playerLayer: The player layer where to display the video.
    ///   - delegates: The delegates of the player events.
    ///   - autoplay: True to play the video when it has been loaded, false to wait for an explicit play.
    public convenience init(
        videoOptions: VideoOptions?,
        playerLayer: AVPlayerLayer,
        delegates: [ApiVideoPlayerControllerPlayerDelegate] = [],
        autoplay: Bool = false
    ) {
        self.init(
            videoOptions: videoOptions,
            delegates: delegates,
            autoplay: autoplay
        )
        playerLayer.player = self.player
    }

    /// Creates a player controller to display the video in a ``AVPlayerViewController``.
    /// - Parameters:
    ///   - videoOptions: The video to play.
    ///   - playerViewController: The player view controller where to display the video.
    ///   - delegates: The delegates of the player events.
    ///   - autoplay: True to play the video when it has been loaded, false to wait for an explicit play.
    public convenience init(
        videoOptions: VideoOptions?,
        playerViewController: AVPlayerViewController,
        delegates: [ApiVideoPlayerControllerPlayerDelegate] = [],
        autoplay: Bool = false
    ) {
        self.init(
            videoOptions: videoOptions,
            delegates: delegates,
            autoplay: autoplay
        )
        playerViewController.setApiVideoPlayerController(self)
    }
    #endif

    /// Creates a player controller without a view.
    /// - Parameters:
    ///   - videoOptions: The video to play.
    ///   - delegates: The delegates of the player events.
    ///   - autoplay: True to play the video when it has been loaded, false to wait for an explicit play.
    ///   - taskExecutor: The executor for the calls to the private session endpoint. Only for test purpose. Default
    /// is``TasksExecutor``.
    public init(
        videoOptions: VideoOptions?,
        delegates: [ApiVideoPlayerControllerPlayerDelegate] = [],
        autoplay: Bool = false,
        taskExecutor: TasksExecutorProtocol.Type = TasksExecutor.self
    ) {
        multicastDelegate.addDelegates(delegates)
        self.taskExecutor = taskExecutor
        self.infoNowPlaying = ApiVideoPlayerInformationNowPlaying(taskExecutor: taskExecutor)

        super.init()
        defer {
            self.videoOptions = videoOptions
        }
        self.autoplay = autoplay
        self.player.addObserver(
            self,
            forKeyPath: "timeControlStatus",
            options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old],
            context: nil
        )
        self.player.addObserver(
            self,
            forKeyPath: "currentItem.presentationSize",
            options: NSKeyValueObservingOptions.new,
            context: nil
        )
        if #available(iOS 15.0, macOS 12.0, *) {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handlePlaybackRateChange(_:)),
                name: AVPlayer.rateDidChangeNotification,
                object: self.player
            )
        } else {
            self.player.addObserver(
                self,
                forKeyPath: "rate",
                options: NSKeyValueObservingOptions.new,
                context: nil
            )
        }
    }

    private func retrySetUpPlayerUrlWithMp4() {
        self.playerItemFactory?.getMp4PlayerItem { currentItem in
            self.preparePlayer(playerItem: currentItem)
        }
    }

    /// Adds the provided player delegate.
    /// When the delegate is not used anymore, it should be removed with ``removeDelegate(_:)``.
    /// - Parameter delegate: The player delegate to be added.
    public func addDelegate(delegate: ApiVideoPlayerControllerPlayerDelegate) {
        multicastDelegate.addDelegate(delegate)
    }

    /// Adds the provided player delegates.
    /// When the delegates are not used anymore, it should be removed with ``removeDelegate(_:)``.
    /// - Parameter delegates: The array of player delegate to be added.
    public func addDelegates(delegates: [ApiVideoPlayerControllerPlayerDelegate]) {
        multicastDelegate.addDelegates(delegates)
    }

    /// Removes the provided delegate.
    /// - Parameter delegate: The player delegate to be removed.
    public func removeDelegate(delegate: ApiVideoPlayerControllerPlayerDelegate) {
        multicastDelegate.removeDelegate(delegate)
    }

    /// Removes the provided delegates.
    /// - Parameter delegates: The array of player delegate to be removed.
    public func removeDelegates(delegates: [ApiVideoPlayerControllerPlayerDelegate]) {
        multicastDelegate.removeDelegates(delegates)
    }

    private func resetPlayer(with playerItem: AVPlayerItem? = nil) {
        if let currentItem = player.currentItem {
            currentItem.removeObserver(self, forKeyPath: "status", context: nil)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: currentItem)
        }

        player.replaceCurrentItem(with: playerItem)
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
        guard let item = player.currentItem else {
            return
        }
        item.add(output)
    }

    public func removeOutput(output: AVPlayerItemOutput) {
        guard let item = player.currentItem else {
            return
        }
        item.remove(output)
    }

    /// Requests invocation of a block during playback to report changing time.
    ///
    /// - Parameter callback: The block to be invoked periodically during playback.
    /// - Returns: You must retain this returned value as long as you want the time observer to be invoked by the
    /// player.
    public func addTimerObserver(callback: @escaping () -> Void) -> Any {
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        return player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: DispatchQueue.main,
            using: { _ in
                callback()
            }
        )
    }

    /// Removes the provided time observer.
    ///
    /// - Parameter observer: The time observer to be removed.
    public func removeTimeObserver(_ observer: Any) {
        player.removeTimeObserver(observer)
    }

    /// Get if the player is playing a live stream.
    /// - Returns: True if the player is playing a live stream
    public var isLive: Bool {
        guard let currentItem = player.currentItem else {
            return false
        }
        return currentItem.duration.isIndefinite
    }

    /// Gets if the player is playing a VOD.
    /// - Returns: True if the player is playing a VOD
    public var isVod: Bool {
        guard let currentItem = player.currentItem else {
            return false
        }
        return !currentItem.duration.isIndefinite
    }

    /// Gets if the video is playing.
    /// - Returns: True if the player is playing a video
    public var isPlaying: Bool {
        self.player.isPlaying
    }

    /// Plays the video.
    public func play() {
        self.player.play()
        if #unavailable(iOS 16.0, macOS 13.0, tvOS 16.0) {
            self.player.rate = storedSpeedRate
        }
    }

    private func seekImpl(to time: CMTime, completion: @escaping (Bool) -> Void) {
        self.player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { completed in
            self.infoNowPlaying.updateCurrentTime(currentTime: time)
            completion(completed)
        }
    }

    /// Seeks to the beginning of the video and plays it.
    public func replay() {
        self.seekImpl(to: CMTime.zero, completion: { _ in
            self.play()
            self.multicastDelegate.didReplay()
        })

    }

    /// Pauses the video.
    public func pause() {
        self.player.pause()
    }

    /// Pauses the video before seeking.
    /// This is useful to avoid spam of delegate calls.
    public func pauseBeforeSeek() {
        self.isSeeking = true
        self.player.pause()
    }

    /// Moves the playback cursor to the ``currentTime`` + offset.
    /// - Parameters:
    ///           - offset: The offset in seconds from the current time (prefix with minus to go backward).
    ///           - completion: The completion block to be called when the seek is completed.
    public func seek(offset: CMTime, completion: @escaping (Bool) -> Void = { _ in
    }) {
        self.seek(to: self.currentTime + offset, completion: completion)
    }

    /// Moves the playback cursor to the provided time.
    /// - Parameters:
    ///           - to: The new playback position.
    ///           - completion: The completion block to be called when the seek is completed.
    public func seek(to: CMTime, completion: @escaping (Bool) -> Void = { _ in
    }) {
        let from = self.currentTime
        self.seekImpl(to: to, completion: { completed in
            completion(completed)
            self.multicastDelegate.didSeek(from, self.currentTime)
        })
    }

    /// Gets and sets the video options.
    public var videoOptions: VideoOptions? {
        didSet {
            self.isFirstPlay = true
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

    /// Gets and sets the playback muted state.
    public var isMuted: Bool {
        get {
            self.player.isMuted
        }
        set(newValue) {
            self.player.isMuted = newValue
            if newValue {
                self.multicastDelegate.didMute()
            } else {
                self.multicastDelegate.didUnMute()
            }
        }
    }

    /// If set to true, the video will loop at the end.
    public var isLooping = false

    /// If set to true, the video will autoplay when ready.
    public var autoplay = false

    /// Gets and sets the video playback volume.
    /// - Parameter volume: The new volume between 0 to 1.
    public var volume: Float {
        get {
            self.player.volume
        }
        set(newVolume) {
            self.player.volume = newVolume
            self.multicastDelegate.didSetVolume(volume)
        }
    }

    /// Get the current video duration.
    /// If the video is live, the duration is the seekable duration.
    /// The duration is invalid if the video is not ready or not set.
    public var duration: CMTime {
        guard let currentItem = player.currentItem else {
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
            return CMTime.invalid
        }
    }

    /// Get the current video position.
    /// The position is invalid if the video is not ready or not set.
    public var currentTime: CMTime {
        self.player.currentTime()
    }

    public var isAtEnd: Bool {
        self.duration.roundedSeconds == self.currentTime.roundedSeconds
    }

    /// Gets the current video size.
    /// - Returns: The video size
    public var videoSize: CGSize {
        self.player.videoSize
    }

    /// Gets if the current video has subtitles.
    /// - Returns: True if the video has subtitles
    public var hasSubtitles: Bool {
        !subtitleLocales.isEmpty
    }

    /// Gets the available subtitles locales.
    /// - Returns: The available subtitles locales
    public var subtitleLocales: [Locale] {
        var locales: [Locale] = []
        if let playerItem = player.currentItem,
           let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible)
        {
            for option in group.options where option.displayName != "CC" {
                if let locale = option.locale {
                    locales.append(locale)
                }
            }
        }
        return locales
    }

    /// Gets the current subtitle locale.
    /// - Returns: The current subtitle locale
    public var currentSubtitleLocale: Locale? {
        if let playerItem = player.currentItem,
           let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible),
           let selectedOption = playerItem.currentMediaSelection.selectedMediaOption(in: group)
        {
            return selectedOption.locale
        }
        return nil
    }

    /// Gets and sets the current playback speed rate.
    /// Expected values are between 0.5 and 2.0.
    public var speedRate: Float {
        get {
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, *) {
                return player.defaultRate
            } else {
                if isPlaying {
                    return player.rate
                } else {
                    return storedSpeedRate
                }
            }
        }
        set(newRate) {
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, *) {
                player.defaultRate = newRate
            } else {
                storedSpeedRate = newRate
            }
            if isPlaying {
                player.rate = newRate
            }
            if #unavailable(iOS 15) {
                // iOS version is less than iOS 15
                infoNowPlaying.updatePlaybackRate(rate: newRate)
            }
        }
    }

    public var enableRemoteControl = false {
        didSet {
            if enableRemoteControl {
                self.setupRemoteControls()
            } else {
                #if !os(macOS)
                UIApplication.shared.endReceivingRemoteControlEvents()
                #endif
            }
        }
    }

    /// Sets the current subtitle locale.
    /// - Parameter locale: The new subtitle locale
    public func setCurrentSubtitleLocale(locale: Locale) {
        if let playerItem = player.currentItem,
           let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible)
        {
            let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
            if let option = options.first {
                playerItem.select(option, in: group)
            }
        }
    }

    /// Hides the current subtitle.
    public func hideSubtitle() {
        guard let playerItem = player.currentItem else {
            return
        }
        if let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) {
            playerItem.select(nil, in: group)
        }
    }

    #if !os(macOS)
    /// Sends the player in fullscreen.
    public func goToFullScreen(viewController: UIViewController) {
        let playerViewController = AVPlayerViewController()
        playerViewController.setApiVideoPlayerController(self)
        // set updatesNowPlayingInfoCenter to false to avoid issue with artwork (blink when play/pause video)
        playerViewController.updatesNowPlayingInfoCenter = false
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
        self.multicastDelegate.didEnd()
    }

    private func setupRemoteControls() {
        let rcc = MPRemoteCommandCenter.shared()
        rcc.skipForwardCommand.preferredIntervals = [15.0]
        rcc.skipBackwardCommand.preferredIntervals = [15.0]
        rcc.skipForwardCommand.addTarget { event in
            guard let event = event as? MPSkipIntervalCommandEvent else {
                return .commandFailed
            }
            self.seek(offset: CMTime(seconds: event.interval, preferredTimescale: 1_000))
            return .success
        }
        rcc.skipBackwardCommand.addTarget { event in
            guard let event = event as? MPSkipIntervalCommandEvent else {
                return .commandFailed
            }
            self.seek(offset: CMTime(seconds: -event.interval, preferredTimescale: 1_000))
            return .success
        }
        rcc.playCommand.addTarget { _ in
            self.play()
            return .success
        }
        rcc.pauseCommand.addTarget { _ in
            self.pause()
            return .success
        }
    }

    private func doFallbackOnFailed() {
        if self.player.currentItem?.status == .failed {
            guard let url = (player.currentItem?.asset as? AVURLAsset)?.url else {
                return
            }
            if url.absoluteString.contains(".mp4") {
                print("Failed to read MP4 video")

                if let error = self.player.currentItem?.error {
                    self.notifyError(error: error)
                } else {
                    self.notifyError(error: PlayerError.playbackFailed("Failed to read HLS and MP4 video"))
                }
                return
            } else {
                print("Failed to read HLS video, retrying with mp4")
                self.retrySetUpPlayerUrlWithMp4()
            }
        }
    }

    private func doReadyToPlay() {
        if self.player.currentItem?.status == .readyToPlay {
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

        self.infoNowPlaying.pause(currentTime: self.currentTime)
        self.multicastDelegate.didPause()
    }

    private func doPlayAction() {
        if self.isSeeking {
            self.isSeeking = false
            return
        }
        if self.isFirstPlay {
            self.isFirstPlay = false
            #if !os(macOS)
            self.infoNowPlaying.nowPlayingData = NowPlayingData(
                duration: self.duration,
                currentTime: self.currentTime,
                isLive: self.isLive,
                thumbnailUrl: self.videoOptions?.thumbnailUrl,
                playbackRate: self.player.rate
            )

            #endif
        } else {
            self.infoNowPlaying.play(currentTime: self.currentTime)
        }
        #if !os(macOS)
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif
        self.multicastDelegate.didPlay()
    }

    @objc
    func handlePlaybackRateChange(_ notification: Notification) {
        guard let player = notification.object as? AVPlayer else {
            return
        }
        infoNowPlaying.updatePlaybackRate(rate: player.rate)
    }

    private func doTimeControlStatus() {
        let status = self.player.timeControlStatus
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
        if keyPath == "rate" {
            infoNowPlaying.updatePlaybackRate(rate: self.player.rate)
        }
    }

    deinit {
        player.removeObserver(self, forKeyPath: "currentItem.presentationSize", context: nil)
        player.removeObserver(self, forKeyPath: "timeControlStatus", context: nil)
        player.currentItem?.removeObserver(self, forKeyPath: "status", context: nil)
        if #unavailable(iOS 15.0, macOS 12.0) {
            player.removeObserver(self, forKeyPath: "rate", context: nil)
        }
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: ApiVideoPlayerItemFactoryDelegate

extension ApiVideoPlayerController: ApiVideoPlayerItemFactoryDelegate {
    public func didError(_ error: Error) {
        self.multicastDelegate.didError(error)
    }
}
