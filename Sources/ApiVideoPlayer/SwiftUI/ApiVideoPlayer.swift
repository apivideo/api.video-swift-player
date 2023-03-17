#if !os(macOS)
import AVKit
import SwiftUI

/// The api.video player view based on AVPlayer
public struct ApiVideoPlayer: UIViewControllerRepresentable {
    private let playerViewController: SwiftUIPlayerViewController

    /// Create a new player view
    /// - Parameters:
    ///   - videoOptions: Description of the video to play.
    ///   - events: List of player events.
    public init(videoOptions: VideoOptions, events: PlayerEvents? = nil) {
        self.playerViewController = SwiftUIPlayerViewController(videoOptions: videoOptions, events: events)
    }

    public func makeUIViewController(context _: Context) -> SwiftUIPlayerViewController {
        return self.playerViewController
    }

    public func updateUIViewController(_: SwiftUIPlayerViewController, context _: Context) {}

    /// Play the video.
    public func play() {
        self.playerViewController.play()
    }

    /// Pause the video.
    public func pause() {
        self.playerViewController.pause()
    }

    /// Get information if the video is playing.
    public var isPlaying: Bool {
        self.playerViewController.isPlaying
    }

    /// Replay the video.
    public func replay() {
        self.playerViewController.replay()
    }

    /// Getter and Setter to mute or unmute video player.
    public var isMuted: Bool {
        get { self.playerViewController.isMuted }
        set(newValue) { self.playerViewController.isMuted = newValue }
    }

    /// Hide all the controls of the player.
    /// By default the controls are on. They will be hide in case of inactivity, and display again on user interaction.
    public func hideControls() {
        self.playerViewController.hideControls()
    }

    /// Show all the controls of the player.
    /// By default the controls are on. They will be hide in case of inactivity, and display again on user interaction.
    public func showControls() {
        self.playerViewController.showControls()
    }

    /// Hide the selected subtitle.
    public func hideSubtitle() {
        self.playerViewController.hideSubtitle()
    }

    /// Go forward or backward in the video to a specific time.
    /// - Parameter offset: offset in seconds, (use minus to go backward).
    public func seek(offset: CMTime) {
        self.playerViewController.seek(offset: offset)
    }

    /// Go forward or backward in the video to a specific time.
    /// - Parameter to: go to a specific time (in second).
    public func seek(to: CMTime) {
        self.playerViewController.seek(to: to)
    }

    /// The video player volume is connected to the device audio volume.
    /// - Parameter volume: Float between 0 to 1.
    public var volume: Float {
        get {
            self.playerViewController.volume
        }
        set(newValue) {
            self.playerViewController.volume = newValue
        }
    }

    /// Get the duration of the video.
    public var duration: CMTime {
        self.playerViewController.duration
    }

    /// Get the current time of the video playing.
    public var currentTime: CMTime {
        self.playerViewController.currentTime
    }

    /// Put the video in full screen.
    /// To be able tu use full screen viewController must be set before.
    public func goToFullScreen() {
        self.playerViewController.goToFullScreen()
    }

    /// Getter and Setter to loop the video.
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
        ApiVideoPlayer(videoOptions: VideoOptions(videoId: "vi2G6Qr8ZVE67dWLNymk7qbc", videoType: .vod))
    }
}
#endif
