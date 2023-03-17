#if !os(macOS)
import AVKit
import UIKit

/// The api.video player view based on AVPlayer
@available(tvOS 10.0, *)
public class ApiVideoPlayerView: UIView {
    private let playerLayer = AVPlayerLayer()
    private let controlsView: ControlsView?
    private let playerController: ApiVideoPlayerController!

    /// The controller that manage the main view (which include the player view).
    /// Set it to be able to use fullscreen and subtitles.
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
        playerController = ApiVideoPlayerController(
            videoOptions: videoOptions,
            playerLayer: playerLayer,
            delegates: [],
            autoplay: autoplay
        )

        if !hideControls {
            controlsView = ControlsView(
                frame: frame,
                playerController: playerController
            )
        } else {
            controlsView = nil
        }
        super.init(frame: frame)

        setupView()
        setupSubviews()
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
        guard let controlsView = controlsView else { return }

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

    /// Add a delegate to multicast delegate to receive player events
    /// - Parameter delegate: The object that acts as the delegate of the PlayerDelegate
    public func addDelegate(_ delegate: PlayerDelegate) {
        playerController.addDelegate(delegate: delegate)
    }

    /// Add multiple delegates to multicast delegate to receive player events
    /// - Parameter delegates: List of objects that acts as the delegates of the PlayerDelegate.
    public func addDelegates(_ delegates: [PlayerDelegate]) {
        playerController.addDelegates(delegates: delegates)
    }

    /// Remove a selected delegate
    /// - Parameter delegate: The object that acts as the delegate which as to be removed.
    public func removeDelegate(_ delegate: PlayerDelegate) {
        playerController.removeDelegate(delegate: delegate)
    }

    /// Remove a list of delegates
    /// - Parameter delegates: List of objects that acts as the delegate which as to be removed
    public func removeDelegates(_ delegates: [PlayerDelegate]) {
        playerController.removeDelegates(delegates: delegates)
    }

    /// Description of the video to play
    public var videoOptions: VideoOptions? {
        get {
            self.playerController.videoOptions
        }
        set {
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
        self.controlsView?.isHidden = true
    }

    /// Show all the controls of the player.
    /// By default the controls are on. They will be hide in case of inactivity, and display again on user interaction.
    public func showControls() {
        self.controlsView?.isHidden = false
    }

    /// Hide the selected subtitle.
    public func hideSubtitle() {
        self.playerController.hideSubtitle()
    }

    /// Get the list of available subtitle locales.
    public var subtitleLocales: [Locale] {
        self.playerController.subtitleLocales
    }

    /// Get the selected subtitle locale.
    /// - Returns: Locale of the selected subtitles.
    public var currentSubtitleLocale: Locale? {
        playerController.currentSubtitleLocale
    }

    /// Set the selected subtitle locale.
    public func setCurrentSubtitleLocale(_ newLocale: Locale) {
        playerController.setCurrentSubtitleLocale(locale: newLocale)
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
