#if !os(macOS)
import AVKit
import UIKit

@available(tvOS 10.0, *)
public class ApiVideoPlayerView: UIView {
    private let playerLayer = AVPlayerLayer()
    private let videoPlayerView = UIView()
    private var controlsView: ControlsView?
    private var playerController: ApiVideoPlayerController!
    private var isFirstPlay = true
    private var isHidenControls: Bool
    public var viewController: UIViewController? {
        didSet {
            self.controlsView?.viewController = self.viewController
        }
    }

    /// Init method for PlayerView.
    /// - Parameters:
    ///   - frame: frame of the player view.
    ///   - videoOptions: The video option containing the videoId and the videoType
    ///   - hideControls: true to hide video controls, false to show them
    ///   - autoplay: true to play the video when it has been loaded, false to wait for an explicit play
    public init(
        frame: CGRect,
        videoOptions: VideoOptions,
        hideControls: Bool = false,
        autoplay: Bool = false
    ) {
        self.isHidenControls = hideControls
        super.init(frame: frame)
        self.playerController = ApiVideoPlayerController(
                videoOptions: videoOptions,
                playerLayer: self.playerLayer,
                delegates: [self],
                autoplay: autoplay
        )
        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .clear
        layer.addSublayer(self.playerLayer)
    }

    private func setupSubviews() {
        guard let controlsView = self.controlsView else {
            return
        }

        // Controls View
        addSubview(controlsView)
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        controlsView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        controlsView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        controlsView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        controlsView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        self.controlsView?.frame = bounds
    }

    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        self.playerLayer.frame = bounds
    }

    public func addDelegate(_ delegate: PlayerDelegate) {
        playerController.addDelegate(delegate: delegate)
    }

    public func addDelegates(_ delegates: [PlayerDelegate]) {
        playerController.addDelegates(delegates: delegates)
    }

    public func removeDelegate(_ delegate: PlayerDelegate) {
        playerController.removeDelegate(delegate: delegate)
    }

    public func removeDelegates(_ delegates: [PlayerDelegate]) {
        playerController.removeDelegates(delegates: delegates)
    }

    public var videoOptions: VideoOptions? {
        get {
            self.playerController.videoOptions
        }
        set {
            // TODO: set ui vod or live
            self.playerController.videoOptions = newValue
        }
    }

    /// Get information if the video is playing.
    /// - Returns: Boolean.
    public var isPlaying: Bool {
        self.playerController.isPlaying
    }

    /// Play the video.
    public func play() {
        self.playerController.play()
    }

    /// Replay the video.
    public func replay() {
        self.playerController.replay()
    }

    /// Pause the video.
    public func pause() {
        self.playerController.pause()
    }

    /// Getter and Setter to mute or unmute video player.
    public var isMuted: Bool {
        get { self.playerController.isMuted }
        set(newValue) { self.playerController.isMuted = newValue }
    }

    /// Hide all the controls of the player.
    /// By default the controls are on. They will be hide in case of inactivity, and display again on user interaction.
    public func hideControls() {
//        self.vodControlsView?.isHidden = true
        self.controlsView?.isHidden = true
    }

    /// Show all the controls of the player.
    /// By default the controls are on. They will be hide in case of inactivity, and display again on user interaction.
    public func showControls() {
//        self.vodControlsView?.isHidden = false
        self.controlsView?.isHidden = false
    }

    /// Hide the selected subtitle.
    public func hideSubtitle() {
        self.playerController.hideSubtitle()
    }

    /// Show the selected subtitles.
    /// - Parameter language: use code language as String (example: "en" for english).
    public var currentSubtitle: Locale {
        get { Locale(identifier: self.playerController.currentSubtitle.language) }
        set(newSubtitle) {
            self.playerController.currentSubtitle = SubtitleLanguage(
                language: newSubtitle.identifier,
                code: newSubtitle.languageCode
            )
        }
    }

    /// Go forward or backward in the video.
    /// - Parameter offset: offset in seconds, (use minus to go backward).
    public func seek(offset: CMTime) {
        self.playerController.seek(offset: offset)
    }

    /// Go forward or backward in the video to a specific time.
    /// - Parameter to: go to a specific time (in second).
    public func seek(to: CMTime) {
        self.playerController.seek(to: to)
    }

    /// The video player volume is connected to the device audio volume.
    /// - Parameter volume: Float between 0 to 1.
    public var volume: Float {
        get {
            self.playerController.volume
        }
        set(newValue) {
            self.playerController.volume = newValue
        }
    }

    /// Get the duration of the video.
    public var duration: CMTime {
        self.playerController.duration
    }

    /// Get the current time of the video playing.
    public var currentTime: CMTime {
        self.playerController.currentTime
    }

    /// Put the video in full screen.
    /// To be able tu use full screen viewController must be set before.
    public func goToFullScreen() {
        guard let vc = viewController else {
            return
        }
        self.playerController.goToFullScreen(viewController: vc)
    }

    /// Getter and Setter to loop the video
    public var isLooping: Bool {
        get {
            self.playerController.isLooping
        }
        set(newValue) {
            self.playerController.isLooping = newValue
        }
    }
}

extension ApiVideoPlayerView: PlayerDelegate {
    public func didPrepare() {
    }

    public func didReady() {
        if !isHidenControls {
            if playerController.isVod {
                let controlsViewOptions = ControlsViewOptions(enableSubtitleButton: playerController.hasSubtitles)
                controlsView = ControlsView.buildForVod(
                        frame: frame,
                        playerController: playerController,
                        controlsViewOptions: controlsViewOptions
                )
            } else {
                let controlsViewOptions = ControlsViewOptions(
                        enableLiveButton: true,
                        enableForwardButton: false,
                        enableBackwardButton: false,
                        enableSubtitleButton: false
                )
                controlsView = ControlsView.buildForLive(
                        frame: frame,
                        playerController: playerController,
                        controlsViewOptions: controlsViewOptions
                )
            }
        }
        setupSubviews()
    }

    public func didPause() {
    }

    public func didPlay() {
    }

    public func didReplay() {
    }

    public func didMute() {
    }

    public func didUnMute() {
    }

    public func didLoop() {
    }

    public func didSetVolume(_ volume: Float) {
    }

    public func didSeek(_ from: CMTime, _ to: CMTime) {
    }

    public func didEnd() {
    }

    public func didError(_ error: Error) {
    }

    public func didVideoSizeChanged(_ size: CGSize) {
    }
}

#else
import Cocoa
public class ApiVideoPlayerView: NSView {
    override public init(frame: NSRect) {
        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        layer?.backgroundColor = NSColor.red.cgColor
    }
}
#endif
