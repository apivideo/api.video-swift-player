#if !os(macOS)
import AVKit
import SwiftUI

public struct ApiVideoPlayer: UIViewControllerRepresentable {
    private let playerViewController: SwiftUIPlayerViewController

    public init(videoId: String, videoType: VideoType, events: PlayerEvents? = nil) {
        self.init(videoOptions: VideoOptions(videoId: videoId, videoType: videoType), events: events)
    }

    public init(videoOptions: VideoOptions, events: PlayerEvents? = nil) {
        self.playerViewController = SwiftUIPlayerViewController(videoOptions: videoOptions, events: events)
    }

    public func makeUIViewController(context _: Context) -> SwiftUIPlayerViewController {
        return self.playerViewController
    }

    public func updateUIViewController(_: SwiftUIPlayerViewController, context _: Context) {}

    public func play() {
        self.playerViewController.play()
    }

    public func pause() {
        self.playerViewController.pause()
    }

    public var isPlaying: Bool {
        return self.playerViewController.isPlaying
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
        ApiVideoPlayer(videoId: "vi2G6Qr8ZVE67dWLNymk7qbc", videoType: .vod)
    }
}
#endif
