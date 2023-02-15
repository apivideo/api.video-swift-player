#if !os(macOS)
import AVKit
import UIKit

public class SwiftUIPlayerViewController: UIViewController {
    let playerView: ApiVideoPlayerView
    private var events: PlayerEvents?
    var del: PlayerEventsDelegate?

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
        self.playerView.addDelegate(self)
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
        super.viewDidDisappear(animated)
    }

    public func addDelegate(delegate: PlayerEventsDelegate) {
        self.playerView.addDelegate(delegate)
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

}

extension SwiftUIPlayerViewController: PlayerEventsDelegate {
    public func didPrepare() {
        self.events?.didPrepare?()
    }

    public func didReady() {
        self.events?.didReady?()
    }

    public func didPause() {
        self.events?.didPause?()
    }

    public func didPlay() {
        self.events?.didPlay?()
    }

    public func didReplay() {
        self.events?.didReplay?()
    }

    public func didMute() {
        self.events?.didMute?()
    }

    public func didUnMute() {
        self.events?.didUnMute?()
    }

    public func didLoop() {
        self.events?.didLoop?()
    }

    public func didSetVolume(_ volume: Float) {
        self.events?.didSetVolume?(volume)
    }

    public func didSeek(_ from: CMTime, _ to: CMTime) {
        self.events?.didSeek?(from, to)
    }

    public func didEnd() {
        self.events?.didEnd?()
    }

    public func didError(_ error: Error) {
        self.events?.didError?(error)
    }

    public func didVideoSizeChanged(_ size: CGSize) {
        self.events?.didVideoSizeChanged?(size)
    }
}
#endif
