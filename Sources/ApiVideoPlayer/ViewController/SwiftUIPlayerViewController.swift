#if !os(macOS)
import AVKit
import UIKit

public class SwiftUIPlayerViewController: UIViewController {

    let playerView: ApiVideoPlayerView

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    init(videoOptions: VideoOptions, events: PlayerEvents? = nil) {
        self.playerView = ApiVideoPlayerView(
            frame: .zero,
            videoOptions: videoOptions,
            events: events
        )
        super.init(nibName: nil, bundle: nil)
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

    override public func viewDidAppear(_: Bool) {
        self.playerView.viewController = self
    }

    override public func viewDidDisappear(_: Bool) {
        self.playerView.viewController = nil
    }

    public func play() {
        self.playerView.play()
    }

    public func pause() {
        self.playerView.pause()
    }

    public var isPlaying: Bool {
        return self.playerView.isPlaying
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
#endif
