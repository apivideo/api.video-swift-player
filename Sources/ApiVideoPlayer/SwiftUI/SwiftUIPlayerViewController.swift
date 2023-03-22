#if !os(macOS)
import AVKit
import UIKit

public class SwiftUIPlayerViewController: UIViewController {
    let playerView: ApiVideoPlayerView

    var onPlay: (() -> Void)?

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    init(autoplay: Bool = false) {
        playerView = ApiVideoPlayerView(
            frame: .zero,
            videoOptions: nil,
            hideControls: false,
            autoplay: autoplay
        )
        super.init(nibName: nil, bundle: nil)
        playerView.addDelegate(self)
        playerView.viewController = self

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
}

extension SwiftUIPlayerViewController: PlayerDelegate {
    public func didPrepare() {
        print("app didPrepare")
    }

    public func didReady() {
        print("app didReady")
    }

    public func didPause() {
        print("app didPause")
    }

    public func didPlay() {
        onPlay?()
    }

    public func didReplay() {
        print("app didReplay")
    }

    public func didMute() {
        print("app didMute")
    }

    public func didUnMute() {
        print("app didUnMute")
    }

    public func didLoop() {
        print("app didLoop")
    }

    public func didSetVolume(_: Float) {
        print("app didSetVolume")
    }

    public func didSeek(_: CMTime, _: CMTime) {
        print("app didSeek")
    }

    public func didEnd() {
        print("app didEnd")
    }

    public func didError(_ error: Error) {
        print("app didError: \(error)")
    }

    public func didVideoSizeChanged(_: CGSize) {}
}
#endif
