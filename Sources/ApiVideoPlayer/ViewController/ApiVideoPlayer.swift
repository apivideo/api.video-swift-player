#if !os(macOS)
import SwiftUI

@available(iOS 14, macOS 11.0, *)
public struct ApiVideoPlayer: UIViewControllerRepresentable {
  private let playerViewController: SwiftUIPlayerViewController

  public init(videoId: String, videoType: VideoType, events: PlayerEvents? = nil) {
    self.playerViewController = SwiftUIPlayerViewController(videoId: videoId, videoType: videoType, events: events)
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

}

@available(iOS 14, macOS 11.0, *)
struct SwiftUIView_Previews: PreviewProvider {
  static var previews: some View {
    ApiVideoPlayer(videoId: "vi2G6Qr8ZVE67dWLNymk7qbc", videoType: .vod)
  }
}
#endif
