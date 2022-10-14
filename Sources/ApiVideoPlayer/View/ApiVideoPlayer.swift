import SwiftUI

@available(iOS 14, macOS 11.0, *)
public struct ApiVideoPlayer: UIViewControllerRepresentable {

  private let videoId: String
  private let videoType: VideoType
  private let viewPlayer: SwiftUIPlayerViewController

  public init(videoId: String, videoType: VideoType, events: PlayerEvents? = nil) {
    self.videoId = videoId
    self.videoType = videoType
    self.viewPlayer = SwiftUIPlayerViewController(videoId: videoId, videoType: videoType, events: events)
  }

  public func makeUIViewController(context _: Context) -> SwiftUIPlayerViewController {
    return self.viewPlayer
  }

  public func updateUIViewController(_: SwiftUIPlayerViewController, context _: Context) {}

  public func play() {
    self.viewPlayer.play()
  }

  public func pause() {
    self.viewPlayer.pause()
  }

}

@available(iOS 14, macOS 11.0, *)
struct SwiftUIView_Previews: PreviewProvider {
  static var previews: some View {
    ApiVideoPlayer(videoId: "vi2G6Qr8ZVE67dWLNymk7qbc", videoType: .vod)
      .frame(height: 250)
  }
}
