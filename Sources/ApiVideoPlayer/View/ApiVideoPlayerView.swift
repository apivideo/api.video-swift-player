#if !os(macOS)
import AVKit
import UIKit

@available(tvOS 10.0, *)
public class ApiVideoPlayerView: UIView {
    private let playerLayer = AVPlayerLayer()
    private let videoPlayerView = UIView()
//    private var vodControlsView: VodControlsView?
    private var controlsView: ControlsView?
    private var playerController: ApiVideoPlayerController
    private var userEvents: PlayerEvents?
    private var isFirstPlay = true
    private var isHidenControls: Bool
    public var viewController: UIViewController? {
        didSet {
            //self.vodControlsView?.viewController = self.viewController
            self.controlsView?.viewController = self.viewController
        }
    }

    /// Init method for PlayerView.
    /// - Parameters:
    ///   - frame: frame of theplayer view.
    ///   - videoId: Need videoid to display the video.
    ///   - videoType: VideoType object to display vod or live controls. Only vod is supported yet.
    ///   - hideControls: true to hide video controls, false to show them
    ///   - autoplay: true to play the video when it has been loaded, false to wait for an explicit play
    ///   - events: Callback to get all the player events.
    public convenience init(
        frame: CGRect,
        videoId: String,
        videoType: VideoType,
        hideControls: Bool = false,
        autoplay: Bool = false,
        events: PlayerEvents? = nil
    ) {
        self.init(
            frame: frame,
            videoOptions: VideoOptions(videoId: videoId, videoType: videoType),
            hideControls: hideControls,
            autoplay: autoplay,
            events: events
        )
    }

    /// Init method for PlayerView.
    /// - Parameters:
    ///   - frame: frame of theplayer view.
    ///   - videoOption: The video option containing the videoId and the videoType
    ///   - hideControls: true to hide video controls, false to show them
    ///   - autoplay: true to play the video when it has been loaded, false to wait for an explicit play
    ///   - events: Callback to get all the player events.
    public init(
        frame: CGRect,
        videoOptions: VideoOptions,
        hideControls: Bool = false,
        autoplay: Bool = false,
        events: PlayerEvents? = nil
    ) {
        self.userEvents = events
        self.isHidenControls = hideControls
        self.playerController = ApiVideoPlayerController(
            videoOptions: videoOptions,
            playerLayer: self.playerLayer,
            autoplay: autoplay,
            events: events
        )
        super.init(frame: frame)
        self.setupView()
        if !hideControls {
            //self.vodControlsView = VodControlsView(frame: frame, playerController: self.playerController)
            self.controlsView = ControlsView(frame: frame, playerController: playerController, videoOptions: videoOptions)
        }

        self.setupSubviews()
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
        // Controls View
        if let controlsView = controlsView{
            addSubview(controlsView)

            controlsView.translatesAutoresizingMaskIntoConstraints = false
            controlsView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            controlsView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            controlsView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            controlsView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
//        self.vodControlsView?.frame = bounds
        self.controlsView?.frame = bounds
    }

    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        self.playerLayer.frame = bounds
    }

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
        return self.playerController.isPlaying
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

    /// Getter and Setter for player events callback.
    /// Use it if you want to get netified on player events.
    public var events: PlayerEvents? {
        get { self.userEvents }
        set(newValue) {
            if let events = userEvents {
                self.playerController.removeEvents(events: events)
            }
            if let events = events {
                self.playerController.addEvents(events: events)
            }
            self.userEvents = newValue
        }
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

    deinit {
        if let events = self.userEvents {
            playerController.removeEvents(events: events)
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
