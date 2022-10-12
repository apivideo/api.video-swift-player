import SwiftUI

@available(iOS 14, macOS 11.0, *)
struct SwiftUIPlayerView: UIViewControllerRepresentable {
  typealias UIViewControllerType = SwiftUIPlayerViewController

  let videoId: String
  let videoType: VideoType
  public var viewPlayer: SwiftUIPlayerViewController

  public init(videoId: String, videoType: VideoType) {
    self.videoId = videoId
    self.videoType = videoType
    let events = PlayerEvents(
      didPause: { () in
        print("paused")
      },
      didPlay: { () in
        print("play")
      },
      didReplay: { () in
        print("video replayed")
      },
      didLoop: { () in
        print("video replayed from loop")
      },
      didSetVolume: { volume in
        print("volume set to : \(volume)")
      },
      didSeek: { from, to in
        print("seek from : \(from), to: \(to)")
      },
      didError: { error in
        print("error \(error)")
      }
    )
    self.viewPlayer = SwiftUIPlayerViewController(videoId: videoId, videoType: videoType, events: events)
  }

  func makeUIViewController(context _: Context) -> SwiftUIPlayerViewController {
    return self.viewPlayer
  }

  func updateUIViewController(_: SwiftUIPlayerViewController, context _: Context) {}

}

@available(iOS 14, macOS 11.0, *)
struct SwiftUIView_Previews: PreviewProvider {
  static var previews: some View {
    SwiftUIPlayerView(videoId: "vi2G6Qr8ZVE67dWLNymk7qbc", videoType: .vod)
      .frame(height: 250)
  }
}
