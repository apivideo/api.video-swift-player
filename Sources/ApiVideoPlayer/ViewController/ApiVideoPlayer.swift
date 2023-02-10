#if !os(macOS)
import AVKit
import SwiftUI

public struct ApiVideoPlayer: UIViewControllerRepresentable {
    private let playerViewController: SwiftUIPlayerViewController

    public init(videoOptions: VideoOptions) {
        self.playerViewController = SwiftUIPlayerViewController(videoOptions: videoOptions)
    }

    public func makeUIViewController(context _: Context) -> SwiftUIPlayerViewController {
        return self.playerViewController
    }

    public func updateUIViewController(_: SwiftUIPlayerViewController, context _: Context) {}

    public func addDelegate(delegate: PlayerEventsDelegate) {
        self.playerViewController.addDelegate(delegate: delegate)
    }

    public func play() {
        self.playerViewController.play()
    }

    public func pause() {
        self.playerViewController.pause()
    }

    public var isPlaying: Bool {
        self.playerViewController.isPlaying
    }

    public func replay() {
        self.playerViewController.replay()
    }

    public var isMuted: Bool {
        get { self.playerViewController.isMuted }
        set(newValue) { self.playerViewController.isMuted = newValue }
    }

    public func hideControls() {
        self.playerViewController.hideControls()
    }

    public func showControls() {
        self.playerViewController.showControls()
    }

    public func hideSubtitle() {
        self.playerViewController.hideSubtitle()
    }

    public func seek(offset: CMTime) {
        self.playerViewController.seek(offset: offset)
    }

    public func seek(to: CMTime) {
        self.playerViewController.seek(to: to)
    }

    public var volume: Float {
        get {
            self.playerViewController.volume
        }
        set(newValue) {
            self.playerViewController.volume = newValue
        }
    }

    public var duration: CMTime {
        self.playerViewController.duration
    }

    public var currentTime: CMTime {
        self.playerViewController.currentTime
    }

    public func goToFullScreen() {
        self.playerViewController.goToFullScreen()
    }

    public var isLooping: Bool {
        get {
            self.playerViewController.isLooping
        }
        set(newValue) {
            self.playerViewController.isLooping = newValue
        }
    }

}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ApiVideoPlayer(videoOptions: VideoOptions(videoId: "vi2G6Qr8ZVE67dWLNymk7qbc"))
    }
}
#endif
