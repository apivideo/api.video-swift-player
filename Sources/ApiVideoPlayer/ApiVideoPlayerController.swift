import ApiVideoPlayerAnalytics
import AVFoundation
import AVKit
import Foundation

@available(iOS 14.0, *)
public class ApiVideoPlayerController: NSObject {
  private var events = [PlayerEvents]()
  private let avPlayer = AVPlayer(playerItem: nil)
  private let offSubtitleLanguage = SubtitleLanguage(language: "Off", code: nil)
  private var analytics: PlayerAnalytics?
  private let videoType: VideoType
  private let videoId: String
  private var playerManifest: PlayerManifest!
  private var timeObserver: Any?
  private var isFirstPlay = true
  private var isSeeking = false

  #if !os(macOS)
  convenience init(
    videoId: String,
    videoType: VideoType,
    playerLayer: AVPlayerLayer,
    events: PlayerEvents? = nil
  ) {
    self.init(videoId: videoId, videoType: videoType, events: events)
    playerLayer.player = self.avPlayer
  }
  #endif

  init(videoId: String, videoType: VideoType, events: PlayerEvents?) {
    self.videoId = videoId
    self.videoType = videoType

    super.init()
    if let events = events {
      self.addEvents(events: events)
    }

    self.getPlayerJSON(videoType: videoType) { error in
      if let error = error {
        self.notifyError(error: error)
      }
    }
  }

    private func getVideoUrl(videoType: VideoType, videoId: String, privateToken: String? = nil) -> String {
    var baseUrl = ""
    if videoType == .vod {
      baseUrl = "https://cdn.api.video/vod/"
    } else {
      baseUrl = "https://live.api.video/"
    }
    var url: String!

    if let privateToken = privateToken {
      url = baseUrl + "\(videoId)/token/\(privateToken)/player.json"
    } else {
      url = baseUrl + "\(videoId)/player.json"
    }

    return url
  }

  private func getPlayerJSON(videoType: VideoType, completion: @escaping (Error?) -> Void) {
    let url = self.getVideoUrl(videoType: videoType, videoId: self.videoId)
    guard let path = URL(string: url) else {
      completion(PlayerError.urlError("Couldn't set up url from this videoId"))
      return
    }
    let request = RequestsBuilder().getPlayerData(path: path)
    let session = RequestsBuilder().buildUrlSession()
    TasksExecutor.execute(session: session, request: request) { data, error in
      if let data = data {
        do {
          self.playerManifest = try JSONDecoder().decode(PlayerManifest.self, from: data)
          self.setUpAnalytics(url: self.playerManifest.video.src)
          try self.setUpPlayer(self.playerManifest.video.src)
          for event in self.events {
            event.didPrepare?()
          }
          completion(nil)
        } catch {
          completion(error)
          return
        }
      } else {
        completion(error)
      }
    }
  }

  private func retrySetUpPlayerUrlWithMp4() {
    guard let mp4 = playerManifest.video.mp4 else {
      print("Error there is no mp4")
      self.notifyError(error: PlayerError.mp4Error("There is no mp4"))
      return
    }
    do {
      try self.setUpPlayer(mp4)
      for event in self.events {
        event.didPrepare?()
      }
    } catch {
      self.notifyError(error: error)
    }
  }

  private func setUpPlayer(_ url: String) throws {
    if let url = URL(string: url) {
      let item = AVPlayerItem(url: url)
      self.avPlayer.currentItem?.removeObserver(self, forKeyPath: "status", context: nil)
      self.avPlayer.replaceCurrentItem(with: item)
      self.avPlayer.addObserver(
        self,
        forKeyPath: "timeControlStatus",
        options: NSKeyValueObservingOptions.new,
        context: nil
      )
      item.addObserver(self, forKeyPath: "status", options: .new, context: nil)
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.playerDidFinishPlaying),
        name: .AVPlayerItemDidPlayToEndTime,
        object: item
      )
    } else {
      throw PlayerError.urlError("bad url")
    }
  }

  private func notifyError(error: Error) {
    for events in self.events {
      events.didError?(error)
    }
  }

  public func addEvents(events: PlayerEvents) {
    self.events.append(events)
  }

  public func removeEvents(events: PlayerEvents) {
    self.events.removeAll { $0 === events }
  }

  public func setTimerObserver(callback: @escaping (() -> Void)) {
    let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    self.timeObserver = self.avPlayer.addPeriodicTimeObserver(
      forInterval: interval,
      queue: DispatchQueue.main,
      using: { _ in
        callback()
      }
    )
  }

  public func removeTimeObserver() {
    if let timeObserver = timeObserver {
      self.avPlayer.removeTimeObserver(timeObserver)
    }
  }

  private func setUpAnalytics(url: String) {
    do {
      let option = try Options(
        mediaUrl: url, metadata: []
      )
      self.analytics = PlayerAnalytics(options: option)
    } catch {
      print("error with the url")
    }
  }

  public func isPlaying() -> Bool {
    return self.avPlayer.isPlaying()
  }

  public func play() {
    self.avPlayer.play()
  }

  public func replay() {
    self.analytics?
      .seek(from: Float(CMTimeGetSeconds(self.currentTime)), to: Float(CMTimeGetSeconds(CMTime.zero))) { result in
        switch result {
        case .success: break

        case let .failure(error):
          print("analytics error on seek event: \(error)")
        }
      }
    self.avPlayer.seek(to: CMTime.zero)
    self.play()
    self.analytics?.resume { result in
      switch result {
      case .success: break

      case let .failure(error):
        print("analytics error on resume event: \(error)")
      }
    }
    for events in self.events {
      events.didReplay?()
    }
  }

  public func pause() {
    self.avPlayer.pause()
  }

  public func pauseBeforeSeek() {
    self.isSeeking = true
    self.avPlayer.pause()
  }

  public func seek(offset: CMTime) {
    self.seek(to: self.currentTime + offset)
  }

  public func seek(to: CMTime) {
    let from = self.currentTime
    self.avPlayer.seek(to: to, toleranceBefore: .zero, toleranceAfter: .zero)
    let calculatedTo = CMTime(
      seconds: min(max(0.0, CMTimeGetSeconds(to)), CMTimeGetSeconds(duration)),
      preferredTimescale: 1_000
    )
    self.analytics?.seek(from: from, to: calculatedTo) { result in
      switch result {
      case .success: break

      case let .failure(error):
        print("analytics error seek: \(error)")
      }
    }

    for events in self.events {
      events.didSeek?(from, calculatedTo)
    }
  }

  public var isMuted: Bool {
    get {
      self.avPlayer.isMuted
    }
    set(newValue) {
      self.avPlayer.isMuted = newValue
      if newValue {
        for events in self.events {
          events.didMute?()
        }
      } else {
        for events in self.events {
          events.didUnMute?()
        }
      }
    }
  }

  public var isLooping = false

  public var volume: Float {
    get { self.avPlayer.volume }
    set(newVolume) {
      self.avPlayer.volume = newVolume
      for events in self.events {
        events.didSetVolume?(volume)
      }
    }
  }

  public var duration: CMTime {
    if let duration = avPlayer.currentItem?.asset.duration {
      return duration
    } else {
      return CMTime(seconds: 0.0, preferredTimescale: 1_000)
    }
  }

  public var currentTime: CMTime {
    self.avPlayer.currentTime()
  }

  public var isAtEnd: Bool {
    self.duration.roundedSeconds == self.currentTime.roundedSeconds
  }

  var hasSubtitles: Bool {
    self.subtitles.count > 1
  }

  var subtitles: [SubtitleLanguage] {
    var subtitles: [SubtitleLanguage] = [offSubtitleLanguage]
    if let playerItem = avPlayer.currentItem,
       let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible)
    {
      for option in group.options where option.displayName != "CC" {
        subtitles.append(SubtitleLanguage(language: option.displayName, code: option.extendedLanguageTag))
      }
    }
    return subtitles
  }

  var currentSubtitle: SubtitleLanguage {
    get {
      if let playerItem = avPlayer.currentItem,
         let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible),
         let selectedOption = playerItem.currentMediaSelection.selectedMediaOption(in: group),
         let locale = selectedOption.locale
      {
        return SubtitleLanguage(language: locale.identifier, code: locale.languageCode)
      }
      return self.offSubtitleLanguage
    }
    set(newSubtitle) {
      if let playerItem = avPlayer.currentItem,
         let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible)
      {
        if newSubtitle.code == nil {
          self.hideSubtitle()
        } else {
          let locale = Locale(identifier: newSubtitle.language)
          let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
          if let option = options.first {
            guard let currentItem = self.avPlayer.currentItem else { return }
            currentItem.select(option, in: group)
          }
        }
      }
    }
  }

  #if !os(macOS)
  public func goToFullScreen(viewController: UIViewController) {
    let playerViewController = AVPlayerViewController()
    playerViewController.player = self.avPlayer
    viewController.present(playerViewController, animated: true) {
      self.play()
    }
  }
  #endif

  func hideSubtitle() {
    guard let currentItem = self.avPlayer.currentItem else { return }
    if let group = currentItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) {
      currentItem.select(nil, in: group)
    }
  }

  @objc
  func playerDidFinishPlaying() {
    if self.isLooping {
      self.replay()
      for events in self.events {
        events.didLoop?()
      }
    }
    self.analytics?.end { result in
      switch result {
      case .success: break

      case let .failure(error):
        print("analytics error on ended event: \(error)")
      }
    }
    for events in self.events {
      events.didEnd?()
    }
  }

  override public func observeValue(
    forKeyPath keyPath: String?,
    of _: Any?,
    change _: [NSKeyValueChangeKey: Any]?,
    context _: UnsafeMutableRawPointer?
  ) {
    if keyPath == "status" {
      if self.avPlayer.currentItem?.status == .failed {
        guard let url = (avPlayer.currentItem?.asset as? AVURLAsset)?.url else {
          return
        }
        if url.absoluteString.contains(".mp4") {
          print("Error with video mp4")
          self.notifyError(error: PlayerError.mp4Error("Tryed mp4 but failed"))
          return
        } else {
          print("Error with video url, trying with mp4")
          self.retrySetUpPlayerUrlWithMp4()
        }
      }
    }
    if keyPath == "timeControlStatus" {
      let status = self.avPlayer.timeControlStatus
      switch status {
      case .paused:
        // Paused mode
        if self.currentTime.second >= self.duration.second {
          break
        }

        if self.isSeeking {
          break
        }

        self.analytics?.pause { result in
          switch result {
          case .success: break

          case let .failure(error):
            print("analytics error on pause event: \(error)")
          }
        }
        for events in self.events {
          events.didPause?()
        }

      case .waitingToPlayAtSpecifiedRate:
        // Resumed
        break

      case .playing:
        // Video Ended
        if self.isSeeking {
          self.isSeeking = false
          break
        }

        if self.isFirstPlay {
          self.isFirstPlay = false
          self.analytics?.play { result in
            switch result {
            case .success: break

            case let .failure(error):
              print("analytics error on play event: \(error)")
            }
          }
        } else {
          self.analytics?.resume { result in
            switch result {
            case .success: break

            case let .failure(error):
              print("analytics error on resume event: \(error)")
            }
          }
        }
        for events in self.events {
          events.didPlay?()
        }
      @unknown default:
        break
      }
    }
  }

  deinit {
    avPlayer.removeObserver(self, forKeyPath: "timeControlStatus", context: nil)
    avPlayer.currentItem?.removeObserver(self, forKeyPath: "status", context: nil)
    NotificationCenter.default.removeObserver(self)
  }
}

extension AVPlayer {
  @available(iOS 10.0, *)
  func isPlaying() -> Bool {
    return (rate != 0 && error == nil)
  }
}

enum PlayerError: Error {
  case mp4Error(String)
  case urlError(String)
  case videoIdError(String)
}
