#if !os(macOS)
import AVFoundation
import Foundation
import UIKit

class VodControlsView: UIView, UIGestureRecognizerDelegate {
  private var timer: Timer?
  private let playerController: ApiVideoPlayerController
  private var subtitleView: SubtitleView?
  private var timeObserver: Any?
  public var viewController: UIViewController? {
    didSet {
      if self.viewController != nil {
        self.fullScreenButton.isHidden = false
      } else {
        self.fullScreenButton.isHidden = true
      }
    }
  }

  private let events = PlayerEvents()
  private var timerLeadingConstraintWithSubtitleButton: NSLayoutConstraint?
  private var timerLeadingConstraintWithoutSubtitleButton: NSLayoutConstraint?

  init(frame: CGRect, playerController: ApiVideoPlayerController) {
    self.playerController = playerController

    super.init(frame: frame)
    self.setup()

    playerController.setTimerObserver(callback: { () in
      self.updateTiming()
    })

    self.events.didPlay = { () in
      self.setPlayBtnIcon(iconName: "pause-primary")
    }
    self.events.didPause = { () in
      self.setPlayBtnIcon(iconName: "play-primary")
    }
    self.events.didEnd = { () in
      self.setPlayBtnIcon(iconName: "replay-primary")
    }

    self.events.didPrepare = { () in
      if playerController.hasSubtitles {
        DispatchQueue.main.async {
          self.timerLeadingConstraintWithoutSubtitleButton?.isActive = false
          self.timerLeadingConstraintWithSubtitleButton?.isActive = true
          self.subtitleButton.isHidden = false
        }
      }
    }

    playerController.addEvents(events: self.events)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  let playPauseButton: UIButton = {
    let btn = UIButton(type: .system)
    btn.tintColor = .white
    btn.contentHorizontalAlignment = .fill
    btn.contentVerticalAlignment = .fill
    btn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    return btn
  }()

  let vodControlGoForward15Button: UIButton = {
    let btn = UIButton(type: .system)
    btn.setImage(UIImage(systemName: "goforward.15"), for: .normal)
    btn.tintColor = .white
    return btn
  }()

  let vodControlGoBackward15Button: UIButton = {
    let btn = UIButton(type: .system)
    btn.setImage(UIImage(systemName: "gobackward.15"), for: .normal)
    btn.tintColor = .white
    return btn
  }()

  let vodControlSliderView: UIView = {
    let view = UIView()
    return view
  }()

  let vodControlSlider: UISlider = {
    let slider = UISlider()
    return slider
  }()

  let vodControlTimerLabel: UILabel = {
    let label = UILabel()
    return label
  }()

  let fullScreenButton: UIButton = {
    let btn = UIButton(type: .system)
    btn.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
    btn.tintColor = .white
    return btn
  }()

  let subtitleButton: UIButton = {
    let btn = UIButton(type: .system)
    btn.setImage(UIImage(systemName: "text.bubble"), for: .normal)
    btn.tintColor = .white
    btn.isHidden = true
    return btn
  }()

  private func setup() {
    // Controls View
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
    tapGestureRecognizer.delegate = self
    addGestureRecognizer(tapGestureRecognizer)
    isUserInteractionEnabled = true

    // Play Pause Button
    addSubview(self.playPauseButton)
    self.playPauseButton.addTarget(self, action: #selector(self.playPauseAction), for: .touchUpInside)
    self.setPlayBtnIcon(iconName: "play-primary")

    // Go Forward Button
    addSubview(self.vodControlGoForward15Button)
    self.vodControlGoForward15Button.addTarget(
      self,
      action: #selector(self.goForward15Action),
      for: .touchUpInside
    )

    // Go Backward Button
    addSubview(self.vodControlGoBackward15Button)
    self.vodControlGoBackward15Button.addTarget(
      self,
      action: #selector(self.goBackward15Action),
      for: .touchUpInside
    )

    // Slider View
    addSubview(self.vodControlSliderView)
    self.vodControlSliderView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.25)

    // Slider
    self.vodControlSliderView.addSubview(self.vodControlSlider)
    self.vodControlSlider.addTarget(
      self,
      action: #selector(self.playbackSliderValueChanged),
      for: .valueChanged
    )
    self.vodControlSlider.tintColor = UIColor.orange.withAlphaComponent(0.7)
    self.vodControlSlider.thumbTintColor = UIColor.white

    // Timer Label
    self.vodControlSliderView.addSubview(self.vodControlTimerLabel)
    self.vodControlTimerLabel.textColor = UIColor.white

    // Subtitle
    self.vodControlSliderView.addSubview(self.subtitleButton)
    self.subtitleButton.addTarget(self, action: #selector(self.toggleSubtitleView), for: .touchUpInside)

    // Full Screen Button
    addSubview(self.fullScreenButton)
    self.fullScreenButton.addTarget(self, action: #selector(self.goToFullScreenAction), for: .touchUpInside)
    self.fullScreenButton.isHidden = true // Will be display if a viewController is set

    self.setupConstraints()
    self.activateTimer()
  }

  private func setupConstraints() {
    // Play Pause Button
    self.playPauseButton.translatesAutoresizingMaskIntoConstraints = false
    self.playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    self.playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    self.playPauseButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
    self.playPauseButton.heightAnchor.constraint(equalToConstant: 70).isActive = true

    // Go Forward Button
    self.vodControlGoForward15Button.translatesAutoresizingMaskIntoConstraints = false
    self.vodControlGoForward15Button.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    self.vodControlGoForward15Button.leadingAnchor.constraint(
      equalTo: self.playPauseButton.trailingAnchor,
      constant: frame.width / 16
    ).isActive = true
    self.vodControlGoForward15Button.widthAnchor.constraint(equalToConstant: 70).isActive = true
    self.vodControlGoForward15Button.heightAnchor.constraint(equalToConstant: 40).isActive = true

    // Go Backward Button
    self.vodControlGoBackward15Button.translatesAutoresizingMaskIntoConstraints = false
    self.vodControlGoBackward15Button.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    self.vodControlGoBackward15Button.trailingAnchor.constraint(
      equalTo: self.playPauseButton.leadingAnchor,
      constant: -(frame.width / 16)
    ).isActive = true
    self.vodControlGoBackward15Button.widthAnchor.constraint(equalToConstant: 70).isActive = true
    self.vodControlGoBackward15Button.heightAnchor.constraint(equalToConstant: 40).isActive = true

    // Slider View
    self.vodControlSliderView.translatesAutoresizingMaskIntoConstraints = false
    self.vodControlSliderView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    self.vodControlSliderView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    self.vodControlSliderView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    self.vodControlSliderView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    self.vodControlSliderView.heightAnchor.constraint(equalToConstant: 50).isActive = true

    // Slider
    self.vodControlSlider.translatesAutoresizingMaskIntoConstraints = false
    self.vodControlSlider.centerYAnchor.constraint(equalTo: self.vodControlSliderView.centerYAnchor)
      .isActive = true
    self.vodControlSlider.leadingAnchor.constraint(
      equalTo: self.vodControlSliderView.leadingAnchor,
      constant: 10
    ).isActive = true
    self.vodControlSlider.rightAnchor.constraint(equalTo: self.vodControlTimerLabel.leftAnchor, constant: -10)
      .isActive = true

    // Timer Label
    self.vodControlTimerLabel.translatesAutoresizingMaskIntoConstraints = false
    self.vodControlTimerLabel.centerYAnchor.constraint(equalTo: self.vodControlSliderView.centerYAnchor)
      .isActive = true
    self.timerLeadingConstraintWithSubtitleButton = self.vodControlTimerLabel.trailingAnchor.constraint(
      equalTo: self.subtitleButton.leadingAnchor,
      constant: -10
    )
    self.timerLeadingConstraintWithoutSubtitleButton = self.vodControlTimerLabel.trailingAnchor.constraint(
      equalTo: self.vodControlSliderView.trailingAnchor,
      constant: -10
    )
    self.timerLeadingConstraintWithoutSubtitleButton?.isActive = true

    self.subtitleButton.translatesAutoresizingMaskIntoConstraints = false
    self.subtitleButton.centerYAnchor.constraint(equalTo: self.vodControlSliderView.centerYAnchor)
      .isActive = true
    self.subtitleButton.trailingAnchor.constraint(
      equalTo: self.vodControlSliderView.trailingAnchor,
      constant: -10
    ).isActive = true

    // FullScreen Button
    self.fullScreenButton.translatesAutoresizingMaskIntoConstraints = false
    self.fullScreenButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
    self.fullScreenButton.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
    self.fullScreenButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
    self.fullScreenButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
  }

  private func hideControls() {
    self.playPauseButton.isHidden = true
    self.vodControlGoForward15Button.isHidden = true
    self.vodControlGoBackward15Button.isHidden = true
    self.vodControlSliderView.isHidden = true
    self.fullScreenButton.isHidden = true
  }

  private func showControls() {
    self.playPauseButton.isHidden = false
    self.vodControlGoForward15Button.isHidden = false
    self.vodControlGoBackward15Button.isHidden = false
    self.vodControlSliderView.isHidden = false
    self.fullScreenButton.isHidden = false
  }

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    // Prevent subviews of a specific view to send touch events to the view's gesture recognizers.
    return touch.view == gestureRecognizer.view
  }

  @objc
  func handleTap(_: UIGestureRecognizer) {
    self.resetTimer()
    self.showControls()
    self.activateTimer()

    self.subtitleView?.dismissView()
  }

  @objc
  func playPauseAction() {
    self.resetTimer()
    if !self.playerController.isPlaying() {
      // Detects end of playing
      if self.playerController.isAtEnd {
        self.playerController.replay()
      } else {
        self.playerController.play()
      }
    } else {
      self.playerController.pause()
    }
    self.activateTimer()
  }

  @objc
  func goForward15Action() {
    self.resetTimer()
    self.playerController.seek(offset: CMTime(seconds: 15, preferredTimescale: 1_000))
    self.activateTimer()
  }

  @objc
  func goBackward15Action() {
    self.resetTimer()
    if self.playerController.isAtEnd {
      self.setPlayBtnIcon(iconName: "play-primary")
    }
    self.playerController.seek(offset: CMTime(seconds: -15, preferredTimescale: 1_000))
    self.activateTimer()
  }

  @objc
  func goToFullScreenAction() {
    guard let vc = viewController else {
      return
    }
    self.playerController.goToFullScreen(viewController: vc)
  }

  @objc
  func toggleSubtitleView() {
    self.resetTimer()
    let posX = self.subtitleButton.frame.origin.x - 120
    let posY = frame.height - self.vodControlSliderView.frame.height - 45

    if let subtitleView = subtitleView,
       subtitleView.isDescendant(of: self)
    {
      subtitleView.dismissView()
    } else {
      subtitleView = {
        let subtitleView = SubtitleView(
          frame: CGRect(x: posX, y: posY, width: 130, height: 3 * 45),
          playerController: playerController
        )
        addSubview(subtitleView)
        bringSubviewToFront(subtitleView)
        return subtitleView
      }()
    }
    self.activateTimer()
  }

  private func activateTimer() {
    guard self.timer == nil else { return }
    self.timer = Timer.scheduledTimer(
      timeInterval: 5,
      target: self,
      selector: #selector(self.hideControlsHandler),
      userInfo: nil,
      repeats: false
    )
  }

  private func resetTimer() {
    self.timer?.invalidate()
    self.timer = nil
  }

  @objc
  func hideControlsHandler() {
    self.hideControls()
  }

  private func setPlayBtnIcon(iconName: String) {
    if #available(tvOS 13.0, *) {
      playPauseButton.setImage(
        UIImage(named: iconName, in: ApiVideoPlayerResources.resourceBundle, compatibleWith: nil),
        for: .normal
      )
    } else {
      // Fallback on earlier versions
    }
  }

  private var sliderDidPauseVideo = false

  @objc
  func playbackSliderValueChanged(slider: UISlider, event: UIEvent) {
    self.resetTimer()
    if let touchEvent = event.allTouches?.first {
      switch touchEvent.phase {
      case .began:
        // handle drag began
        if self.playerController.isPlaying() {
          // Avoid to trigger callbacks and analytics when the user uses the seek slider
          self.playerController.pauseBeforeSeek()
          self.sliderDidPauseVideo = true
        }

      case .moved:
        // handle drag moved
        break

      case .ended:
        // handle drag ended
        let value = Float64(slider.value) * CMTimeGetSeconds(self.playerController.duration)
        self.playerController.seek(to: CMTime(seconds: value, preferredTimescale: 1_000))
        if self.sliderDidPauseVideo {
          self.playerController.play()
        }
        self.sliderDidPauseVideo = false

      default:
        break
      }
    }
    self.activateTimer()
  }

  private func updateTiming() {
    let currentTime = self.playerController.currentTime
    let duration = self.playerController.duration
    let remainingTime = duration - currentTime

    self.vodControlSlider.value = Float(currentTime.roundedSeconds / duration.roundedSeconds)

    self.vodControlTimerLabel.text = remainingTime.prettyTime
  }

  deinit {
    playerController.removeEvents(events: events)
    playerController.removeTimeObserver()
  }

}
#endif
