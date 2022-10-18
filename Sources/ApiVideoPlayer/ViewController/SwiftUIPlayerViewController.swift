#if !os(macOS)
import UIKit

@available(iOS 14.0, *)
public class SwiftUIPlayerViewController: UIViewController {
  let videoId: String
  let videoType: VideoType
  let events: PlayerEvents?

  var playerView: ApiVideoPlayerView

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) is not supported")
  }

  init(videoId: String, videoType: VideoType, events: PlayerEvents? = nil) {
    self.videoId = videoId
    self.videoType = videoType
    self.events = events

    self.playerView = ApiVideoPlayerView(
      frame: .zero,
      videoId: self.videoId,
      videoType: self.videoType /* only .vod is supported */,
      events: self.events
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

  public func play() {
    self.playerView.play()
  }

  public func pause() {
    self.playerView.pause()
  }

}
#endif
