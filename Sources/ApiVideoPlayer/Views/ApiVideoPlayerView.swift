#if !os(macOS)
import AVKit
import UIKit

/// The api.video player view for UIKit.
@available(tvOS 10.0, *)
public class ApiVideoPlayerView: UIView {
    private let playerLayer = AVPlayerLayer()
    private let controlsView: ControlsView?
    private let playerController: ApiVideoPlayerController!

    /// Initializes a player view for UIKit.
    /// - Parameters:
    ///   - frame: The frame of the player view.
    ///   - videoOptions: The video to play. Could be nil if you don't know the video when instantiating the view.
    ///   - hideControls: True to hide video controls, false to show them.
    ///   - autoplay: True to play the video when it has been loaded, false to wait for an explicit play.
    public init(
        frame: CGRect,
        videoOptions: VideoOptions?,
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
        guard let controlsView = controlsView else {
            return
        }

        // Controls Views
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

    /// Adds the provided player delegate.
    /// When the delegate is not used anymore, it should be removed with ``removeDelegate(_:)``.
    /// - Parameter delegate: The player delegate to be added.
    public func addDelegate(_ delegate: ApiVideoPlayerControllerPlayerDelegate) {
        playerController.addDelegate(delegate: delegate)
    }

    /// Adds the provided player delegates.
    /// When the delegates are not used anymore, it should be removed with ``removeDelegate(_:)``.
    /// - Parameter delegates: The array of player delegate to be added.
    public func addDelegates(_ delegates: [ApiVideoPlayerControllerPlayerDelegate]) {
        playerController.addDelegates(delegates: delegates)
    }

    /// Removes the provided delegate.
    /// - Parameter delegate: The player delegate to be removed.
    public func removeDelegate(_ delegate: ApiVideoPlayerControllerPlayerDelegate) {
        playerController.removeDelegate(delegate: delegate)
    }

    /// Removes the provided delegates.
    /// - Parameter delegates: The array of player delegate to be removed.
    public func removeDelegates(_ delegates: [ApiVideoPlayerControllerPlayerDelegate]) {
        playerController.removeDelegates(delegates: delegates)
    }

    /// The view controller that manages this view.
    /// Set it to be able to use fullscreen.
    /// If set to nil, fullscreen button is hidden.
    public var viewController: UIViewController? {
        didSet {
            self.controlsView?.viewController = self.viewController
        }
    }

    /// Gets and sets the video options.
    public var videoOptions: VideoOptions? {
        get {
            self.playerController.videoOptions
        }
        set {
            self.playerController.videoOptions = newValue
        }
    }

    /// Gets if the video is playing.
    /// - Returns: True if the player is playing a video
    public var isPlaying: Bool {
        self.playerController.isPlaying
    }

    /// Plays the video.
    public func play() {
        self.playerController.play()
    }

    /// Seeks to the beginning of the video and plays it.
    public func replay() {
        self.playerController.replay()
    }

    /// Pauses the video.
    public func pause() {
        self.playerController.pause()
    }

    /// Gets and sets the playback muted state.
    public var isMuted: Bool {
        get {
            self.playerController.isMuted
        }
        set(newValue) {
            self.playerController.isMuted = newValue
        }
    }

    /// Hides all the controls of the player.
    public func hideControls() {
        self.controlsView?.isHidden = true
    }

    /// Shows all the controls of the player.
    /// The controls will be hidden in case of inactivity, and display again on user interaction.
    public func showControls() {
        self.controlsView?.isHidden = false
    }

    /// Hides the current subtitle.
    public func hideSubtitle() {
        self.playerController.hideSubtitle()
    }

    /// Gets the list of available subtitle locales.
    public var subtitleLocales: [Locale] {
        self.playerController.subtitleLocales
    }

    /// Gets the selected subtitle locale.
    /// - Returns: Locale of the selected subtitles.
    public var currentSubtitleLocale: Locale? {
        playerController.currentSubtitleLocale
    }

    /// Sets the selected subtitle locale.
    public func setCurrentSubtitleLocale(_ newLocale: Locale) {
        playerController.setCurrentSubtitleLocale(locale: newLocale)
    }

    /// Moves the playback cursor to the ``currentTime`` + offset.
    /// - Parameter offset: The offset in seconds from the current time (prefix with minus to go backward).
    public func seek(offset: CMTime) {
        self.playerController.seek(offset: offset)
    }

    /// Moves the playback cursor to the provided time.
    /// - Parameter to: The new playback position.
    public func seek(to: CMTime) {
        self.playerController.seek(to: to)
    }

    /// Gets and sets the video playback volume.
    /// - Parameter volume: The new volume between 0 to 1.
    public var volume: Float {
        get {
            self.playerController.volume
        }
        set(newValue) {
            self.playerController.volume = newValue
        }
    }

    /// Gets the duration of the current video.
    /// The duration is invalid if the video is not ready or not set.
    public var duration: CMTime {
        self.playerController.duration
    }

    /// Gets the playback position of the current video.
    /// The position is invalid if the video is not ready or not set.
    public var currentTime: CMTime {
        self.playerController.currentTime
    }

    /// Sends the player in fullscreen.
    /// To be able tu use fullscreen, ``viewController`` must not be nil.
    public func goToFullScreen() {
        guard let vc = viewController else {
            return
        }
        self.playerController.goToFullScreen(viewController: vc)
    }

    /// Gets and sets the video loop.
    /// If set to true, the video will loop at the end.
    public var isLooping: Bool {
        get {
            self.playerController.isLooping
        }
        set(newValue) {
            self.playerController.isLooping = newValue
        }
    }

    /// Pass events received from remote control, to handle actions.
    /// - Parameter event: event of type remoteControl
    public func remoteControlEventReceived(with event: UIEvent?) {
        self.playerController.remoteControlEventReceived(with: event)
    }

    /// Allow video interaction with the remote control on lockscreen and notification center
    public func allowRemoteControl() {
        self.playerController.allowRemoteControl()
    }

    /// Remove remote control from lockscreen and notification center
    public func removeRemoteControl() {
        self.playerController.removeRemoteControl()
    }
}

#else
import Cocoa

/// The api.video player view for AppKit.
/// This view is not implemented yet.
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
