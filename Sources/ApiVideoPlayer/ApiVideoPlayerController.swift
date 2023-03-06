import ApiVideoPlayerAnalytics
import AVFoundation
import AVKit
import Foundation

public class ApiVideoPlayerController: NSObject {
    private let avPlayer = AVPlayer(playerItem: nil)
    private let offSubtitleLanguage = SubtitleLanguage(language: "Off", code: nil)
    private var analytics: PlayerAnalytics?
    private var playerManifest: PlayerManifest!
    private var timeObserver: Any?
    private var isFirstPlay = true
    private var isSeeking = false
    private let taskExecutor: TasksExecutorProtocol.Type
    private let multicastDelegate = ApiVideoPlayerControllerMulticastDelegate()

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
        } else { url = baseUrl + "\(videoOptions.videoId)/player.json" }
        return url
    }

    private func getPlayerJSON(videoOptions: VideoOptions, completion: @escaping (Error?) -> Void) {
        let url = self.getVideoUrl(videoOptions: videoOptions)
        guard let path = URL(string: url) else {
            completion(PlayerError.urlError("Couldn't set up url from this videoId"))
            return
        }
        let request = RequestsBuilder().getPlayerData(path: path)
        let session = RequestsBuilder().buildUrlSession()
        self.taskExecutor.execute(session: session, request: request) { data, error in
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
            self.notifyError(error: PlayerError.mp4Error("There is no mp4"))
            return
        }
        do {
            try self.setUpPlayer(mp4)
        } catch {
            self.notifyError(error: error)
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

    private func setUpPlayer(_ url: String) throws {
        if let url = URL(string: url) {
            self.multicastDelegate.didPrepare()
            let item = AVPlayerItem(url: url)
            self.avPlayer.currentItem?.removeObserver(self, forKeyPath: "status", context: nil)
            self.avPlayer.replaceCurrentItem(with: item)
            item.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.playerDidFinishPlaying),
                name: .AVPlayerItemDidPlayToEndTime,
                object: item
            )
        } else {
            throw PlayerError.urlError("bad url")
        }
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
        } catch { print("error with the url") }
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

    public func seek(offset: CMTime, completion: @escaping (Bool) -> Void = { _ in }) {
        self.seek(to: self.currentTime + offset, completion: completion)
    }

    public func seek(to: CMTime, completion: @escaping (Bool) -> Void = { _ in }) {
        let from = self.currentTime
        self.seekImpl(to: to, completion: { completed in
            completion(completed)
            self.multicastDelegate.didSeek(from, self.currentTime)
        })
    }

    public var videoOptions: VideoOptions? {
        didSet {
            guard let videoOptions = videoOptions else {
                return
            }

            self.getPlayerJSON(videoOptions: videoOptions) { error in
                if let error = error {
                    self.notifyError(error: error)
                }
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
        get { self.avPlayer.volume }
        set(newVolume) {
            self.avPlayer.volume = newVolume
            self.multicastDelegate.didSetVolume(volume)
        }
    }

    public var duration: CMTime {
        guard let videoOptions = self.videoOptions else {
            return CMTime(seconds: 0.0, preferredTimescale: 1_000)
        }
        guard let currentItem = avPlayer.currentItem else {
            return CMTime(seconds: 0.0, preferredTimescale: 1_000)

        }
        if videoOptions.videoType == .vod {
            return currentItem.asset.duration
        } else {
            let seekableDuration = currentItem.seekableTimeRanges.last?.timeRangeValue.end.seconds ?? 0.0
            return CMTime(seconds: seekableDuration, preferredTimescale: 1_000)
        }
    }

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
        self.subtitles.count > 1
    }

    public var subtitles: [SubtitleLanguage] {
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

    public var currentSubtitle: SubtitleLanguage {
        get {
            if let playerItem = avPlayer.currentItem,
               let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible),
               let selectedOption = playerItem.currentMediaSelection.selectedMediaOption(in: group)
            {
                return SubtitleLanguage(language: selectedOption.displayName, code: selectedOption.extendedLanguageTag)
            }
            return self.offSubtitleLanguage
        }
        set(newSubtitle) {
            if let playerItem = avPlayer.currentItem,
               let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible)
            {
                if let code = newSubtitle.code {
                    let locale = Locale(identifier: code)
                    let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
                    if let option = options.first {
                        guard let currentItem = self.avPlayer.currentItem else { return }
                        currentItem.select(option, in: group)
                    }
                } else {
                    self.hideSubtitle()
                }
            }
        }
    }

    #if !os(macOS)
    public func goToFullScreen(viewController: UIViewController) {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = self.avPlayer
        viewController.present(playerViewController, animated: true) { self.play() }
    }
    #endif

    public func hideSubtitle() {
        guard let currentItem = self.avPlayer.currentItem else { return }
        if let group = currentItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) {
            currentItem.select(nil, in: group)
        }
    }

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
                print("Error with video mp4")
                self.notifyError(error: PlayerError.mp4Error("Tryed mp4 but failed"))
                return
            } else {
                print("Error with video url, trying with mp4")
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
            guard let change = change else { return }
            guard let newValue = change[.newKey] as? Int else { return }
            guard let oldValue = change[.oldKey] as? Int else { return }
            if oldValue != newValue {
                self.doTimeControlStatus()
            }
        }
        if keyPath == "currentItem.presentationSize" {
            guard let change = change else { return }
            guard let newSize = change[.newKey] as? CGSize else { return }
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

extension AVPlayer {
    @available(iOS 10.0, *)
    var isPlaying: Bool {
        rate != 0 && error == nil
    }

    var videoSize: CGSize {
        guard let size = self.currentItem?.presentationSize else {
            return .zero
        }
        return size
    }
}

enum PlayerError: Error {
    case mp4Error(String)
    case urlError(String)
    case videoIdError(String)
}
