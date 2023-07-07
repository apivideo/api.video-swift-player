#if !os(macOS)
import AVKit
import SwiftUI

/// The api.video player view for SwiftUI.
@available(iOS 13.0, *)
public struct ApiVideoPlayer: UIViewControllerRepresentable {
    private let playerViewController: SwiftUIPlayerViewController

    /// Initializes a player view for SwiftUI.
    /// - Parameters:
    ///   - videoOptions: The video to play.
    ///   - events: The player events.
    public init(videoOptions: VideoOptions, events: PlayerEvents? = nil, autoplay: Bool = false) {
        self.playerViewController = SwiftUIPlayerViewController(
            videoOptions: videoOptions,
            events: events,
            autoplay: autoplay
        )
    }

    public func makeUIViewController(context _: Context) -> SwiftUIPlayerViewController {
        return self.playerViewController
    }

    public func updateUIViewController(_: SwiftUIPlayerViewController, context _: Context) {}

    /// Plays the video.
    public func play() {
        self.playerViewController.play()
    }

    /// Pauses the video.
    public func pause() {
        self.playerViewController.pause()
    }

    /// Gets if the video is playing.
    public var isPlaying: Bool {
        self.playerViewController.isPlaying
    }

    /// Replays the video.
    public func replay() {
        self.playerViewController.replay()
    }

    /// Gets and sets the playback muted state.
    public var isMuted: Bool {
        get { self.playerViewController.isMuted }
        set(newValue) { self.playerViewController.isMuted = newValue }
    }

    /// Hides all the controls of the player.
    public func hideControls() {
        self.playerViewController.hideControls()
    }

    /// Shows all the controls of the player.
    /// The controls will be hidden in case of inactivity, and display again on user interaction.
    public func showControls() {
        self.playerViewController.showControls()
    }

    /// Hides the current subtitle.
    public func hideSubtitle() {
        self.playerViewController.hideSubtitle()
    }

    /// Moves the playback cursor to the ``currentTime`` + offset.
    /// - Parameter offset: The offset in seconds from the current time (prefix with minus to go backward).
    public func seek(offset: CMTime) {
        self.playerViewController.seek(offset: offset)
    }

    /// Moves the playback cursor to the provided time.
    /// - Parameter to: The new playback position.
    public func seek(to: CMTime) {
        self.playerViewController.seek(to: to)
    }

    /// Gets and sets the video playback volume.
    /// - Parameter volume: The new volume between 0 to 1.
    public var volume: Float {
        get {
            self.playerViewController.volume
        }
        set(newValue) {
            self.playerViewController.volume = newValue
        }
    }

    /// Gets the duration of the current video.
    /// The duration is invalid if the video is not ready or not set.
    public var duration: CMTime {
        self.playerViewController.duration
    }

    /// Gets the playback position of the current video.
    /// The position is invalid if the video is not ready or not set.
    public var currentTime: CMTime {
        self.playerViewController.currentTime
    }

    /// Sends the player in fullscreen.
    public func goToFullScreen() {
        self.playerViewController.goToFullScreen()
    }

    /// Gets and sets the video loop.
    /// If set to true, the video will loop at the end.
    public var isLooping: Bool {
        get {
            self.playerViewController.isLooping
        }
        set(newValue) {
            self.playerViewController.isLooping = newValue
        }
    }

    /// Toggle the visibility of the remote control.
    /// Setting it to true will display it, while setting it to False will hide it.
    /// By default the remote is hidden.
    public var enableRemoteControl: Bool {
        get {
            self.playerViewController.enableRemoteControl
        }
        set(newValue) {
            self.playerViewController.enableRemoteControl = newValue
        }
    }

}

@available(iOS 13.0.0, *)
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ApiVideoPlayer(videoOptions: VideoOptions(videoId: "vi2G6Qr8ZVE67dWLNymk7qbc", videoType: .vod))
    }
}
#endif
