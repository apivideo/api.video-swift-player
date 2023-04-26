#if !os(macOS)
import AVKit
import UIKit

public class SwiftUIPlayerViewController: UIViewController {
    let playerView: ApiVideoPlayerView
    private var events: PlayerEvents?

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    init(videoOptions: VideoOptions, events: PlayerEvents? = nil) {
        self.playerView = ApiVideoPlayerView(
            frame: .zero,
            videoOptions: videoOptions
        )
        self.events = events
        super.init(nibName: nil, bundle: nil)
        playerView.addDelegate(self)
    }

    deinit {
        playerView.removeDelegate(self)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(self.playerView)
        self.playerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.playerView.topAnchor.constraint(equalTo: view.topAnchor),
            self.playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override public func viewDidAppear(_ animated: Bool) {
        self.playerView.viewController = self
        super.viewDidAppear(animated)
    }

    override public func viewDidDisappear(_ animated: Bool) {
        self.playerView.viewController = nil
        UIApplication.shared.endReceivingRemoteControlEvents()
        super.viewDidDisappear(animated)
    }

    public func play() {
        self.playerView.play()
    }

    public func pause() {
        self.playerView.pause()
    }

    public var isPlaying: Bool {
        self.playerView.isPlaying
    }

    public func replay() {
        self.playerView.replay()
    }

    public var isMuted: Bool {
        get { self.playerView.isMuted }
        set(newValue) { self.playerView.isMuted = newValue }
    }

    public func hideControls() {
        self.playerView.hideControls()
    }

    public func showControls() {
        self.playerView.showControls()
    }

    public func hideSubtitle() {
        self.playerView.hideSubtitle()
    }

    public func seek(offset: CMTime) {
        self.playerView.seek(offset: offset)
    }

    public func seek(to: CMTime) {
        self.playerView.seek(to: to)
    }

    public var volume: Float {
        get {
            self.playerView.volume
        }
        set(newValue) {
            self.playerView.volume = newValue
        }
    }

    public var duration: CMTime {
        self.playerView.duration
    }

    public var currentTime: CMTime {
        self.playerView.currentTime
    }

    public func goToFullScreen() {
        self.playerView.goToFullScreen()
    }

    public var isLooping: Bool {
        get {
            self.playerView.isLooping
        }
        set(newValue) {
            self.playerView.isLooping = newValue
        }
    }

    public var enableRemoteControl: Bool = false {
        didSet {
            self.playerView.enableRemotteControl = enableRemoteControl
        }
    }

}

extension SwiftUIPlayerViewController: ApiVideoPlayerControllerPlayerDelegate {
    public func didPrepare() {
        events?.didPrepare?()
    }

    public func didReady() {
        events?.didReady?()
    }

    public func didPause() {
        events?.didPause?()
    }

    public func didPlay() {
        events?.didPlay?()
    }

    public func didReplay() {
        events?.didReplay?()
    }

    public func didMute() {
        events?.didMute?()
    }

    public func didUnMute() {
        events?.didUnmute?()
    }

    public func didLoop() {
        events?.didLoop?()
    }

    public func didSetVolume(_ volume: Float) {
        events?.didSetVolume?(volume)
    }

    public func didSeek(_ from: CMTime, _ to: CMTime) {
        events?.didSeek?(from, to)
    }

    public func didEnd() {
        events?.didEnd?()
    }

    public func didError(_ error: Error) {
        events?.didError?(error)
    }

    public func didVideoSizeChanged(_ size: CGSize) {
        events?.didVideoSizeChanged?(size)
    }
}
#endif
