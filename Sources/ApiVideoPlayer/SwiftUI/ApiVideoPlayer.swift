#if !os(macOS)
import AVKit
import SwiftUI

/// The api.video player view for SwiftUI.
public struct ApiVideoPlayer: UIViewControllerRepresentable {
    let autoplay: Bool

    @Binding var isPlaying: Bool

    @Binding var hideControls: Bool

    @Binding var videoOptions: VideoOptions?

    private var onPlay: (() -> Void)?

    /// Initializes a player view for SwiftUI.
    /// - Parameters:
    ///   - TODO
    public init(
        videoOptions: Binding<VideoOptions?>,
        isPlaying: Binding<Bool>,
        hideControls: Binding<Bool> = .constant(false),
        autoplay: Bool = false
    ) {
        self._videoOptions = videoOptions

        self._isPlaying = isPlaying

        self._hideControls = hideControls
        self.autoplay = autoplay
    }

    public func makeUIViewController(context _: Context) -> SwiftUIPlayerViewController {
        SwiftUIPlayerViewController(autoplay: autoplay)
    }

    public func updateUIViewController(_ playerViewController: SwiftUIPlayerViewController, context _: Context) {
        playerViewController.onPlay = onPlay

        if isPlaying != playerViewController.playerView.isPlaying {
            if isPlaying {
                playerViewController.playerView.play()
            } else {
                playerViewController.playerView.pause()
            }
        }

        if hideControls {
            playerViewController.playerView.hideControls()
        } else {
            playerViewController.playerView.showControls()
        }
        if playerViewController.playerView.videoOptions != videoOptions {
            playerViewController.playerView.videoOptions = videoOptions
        }
    }

    public func onPlay(perform action: (() -> Void)?) -> Self {
        var copy = self
        copy.onPlay = action
        return copy
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ApiVideoPlayer(
            videoOptions: .constant(VideoOptions(videoId: "YOUR_VIDEO_ID", videoType: VideoType.vod)),
            isPlaying: .constant(true)
        )
    }
}
#endif
