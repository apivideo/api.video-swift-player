#if !os(macOS)
import AVFoundation
import Foundation
import UIKit

class ControlsView: UIView, UIGestureRecognizerDelegate {
    private let playerController: ApiVideoPlayerController
    private let videoOptions: VideoOptions

    private var timer: Timer?
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

    init(frame: CGRect, playerController: ApiVideoPlayerController, videoOptions: VideoOptions) {
        self.playerController = playerController
        self.videoOptions = videoOptions
        super.init(frame: frame)
        playerController.setTimerObserver(callback: { () in
            self.updateTiming()
        })
        self.setGenericButtons()
        if videoOptions.videoType == .vod {
            self.setVodView()
        } else {
            self.setLiveView()
        }

        self.setupGeneralEvents()

        playerController.addEvents(events: self.events)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setGenericButtons() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tapGestureRecognizer.delegate = self
        addGestureRecognizer(tapGestureRecognizer)
        isUserInteractionEnabled = true

        // Play Pause Button
        addSubview(self.playPauseButton)
        self.playPauseButton.addTarget(self, action: #selector(self.playPauseAction), for: .touchUpInside)
        self.setPlayBtnIcon(iconName: "play-primary")

        // Slider View
        addSubview(self.controlSliderView)
        self.controlSliderView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.25)

        // Slider
        self.controlSliderView.addSubview(self.controlSlider)
        self.controlSlider.addTarget(
            self,
            action: #selector(self.playbackSliderValueChanged),
            for: .valueChanged
        )
        self.controlSlider.tintColor = UIColor.orange.withAlphaComponent(0.7)
        self.controlSlider.thumbTintColor = UIColor.white

        addSubview(self.fullScreenButton)
        self.fullScreenButton.addTarget(self, action: #selector(self.goToFullScreenAction), for: .touchUpInside)
        self.fullScreenButton.isHidden = true

        self.setupGeneralConstraints()
    }

    private func setupGeneralConstraints() {
        // Play Pause Button
        self.playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        self.playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        self.playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.playPauseButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        self.playPauseButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        // Slider View
        self.controlSliderView.translatesAutoresizingMaskIntoConstraints = false
        self.controlSliderView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        self.controlSliderView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        self.controlSliderView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        self.controlSliderView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        // Slider
        self.controlSlider.translatesAutoresizingMaskIntoConstraints = false
        self.controlSlider.centerYAnchor.constraint(equalTo: self.controlSliderView.centerYAnchor)
            .isActive = true
        self.controlSlider.leadingAnchor.constraint(
            equalTo: self.controlSliderView.leadingAnchor,
            constant: 10
        ).isActive = true

        // FullScreen Button
        self.fullScreenButton.translatesAutoresizingMaskIntoConstraints = false
        self.fullScreenButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        self.fullScreenButton.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        self.fullScreenButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        self.fullScreenButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }

    private func setupVodConstraints() {
        self.controlSliderView.heightAnchor.constraint(equalToConstant: 50).isActive = true

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

        // Slider right anchor
        self.controlSlider.rightAnchor.constraint(equalTo: self.controlTimerLabel.leftAnchor, constant: -10)
            .isActive = true

        // Timer Label
        self.controlTimerLabel.translatesAutoresizingMaskIntoConstraints = false
        self.controlTimerLabel.centerYAnchor.constraint(equalTo: self.controlSliderView.centerYAnchor)
            .isActive = true

        self.timerLeadingConstraintWithSubtitleButton = self.controlTimerLabel.trailingAnchor.constraint(
            equalTo: self.subtitleButton.leadingAnchor,
            constant: -10
        )
        self.timerLeadingConstraintWithoutSubtitleButton = self.controlTimerLabel.rightAnchor.constraint(
            equalTo: self.controlSliderView.rightAnchor,
            constant: -10
        )
        self.timerLeadingConstraintWithoutSubtitleButton?.isActive = true

        // subtitle
        self.subtitleButton.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleButton.centerYAnchor.constraint(equalTo: self.controlSliderView.centerYAnchor)
            .isActive = true
        self.subtitleButton.trailingAnchor.constraint(
            equalTo: self.controlSliderView.trailingAnchor,
            constant: -10
        ).isActive = true

    }

    private func setupLiveConstraints() {
        // sliderview height
        self.controlSliderView.heightAnchor.constraint(equalToConstant: 60).isActive = true

        // Slider right anchor
        self.controlSlider.rightAnchor.constraint(equalTo: self.liveButton.leftAnchor, constant: -10)
            .isActive = true

        self.liveButton.translatesAutoresizingMaskIntoConstraints = false
        self.liveButton.centerYAnchor.constraint(equalTo: self.controlSliderView.centerYAnchor)
            .isActive = true
        self.liveButton.rightAnchor.constraint(
            equalTo: self.controlSliderView.rightAnchor,
            constant: -10
        ).isActive = true

        self.liveButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        self.liveButton.heightAnchor.constraint(equalToConstant: 25).isActive = true

        self.controlLiveCurrentTimerLabel.translatesAutoresizingMaskIntoConstraints = false
        self.controlLiveCurrentTimerLabel.topAnchor.constraint(equalTo: self.controlSlider.bottomAnchor)
            .isActive = true
        self.controlLiveCurrentTimerLabel.leadingAnchor.constraint(
            equalTo: self.controlSliderView.leadingAnchor,
            constant: 10
        ).isActive = true

        self.controlTimeToLiveLabel.translatesAutoresizingMaskIntoConstraints = false
        self.controlTimeToLiveLabel.centerXAnchor.constraint(equalTo: self.liveButton.centerXAnchor)
            .isActive = true
        self.controlTimeToLiveLabel.topAnchor.constraint(equalTo: self.liveButton.bottomAnchor).isActive = true

    }

    private func setLiveView() {
        self.controlSliderView.addSubview(self.liveButton)
        self.controlSliderView.addSubview(self.controlLiveCurrentTimerLabel)
        self.controlSliderView.addSubview(self.controlTimeToLiveLabel)

        self.liveButton.addTarget(self, action: #selector(self.goToLive), for: .touchUpInside)
        self.controlLiveCurrentTimerLabel.text = "00:00"
        self.controlTimeToLiveLabel.text = "00:00"

        self.controlLiveCurrentTimerLabel.font = self.controlLiveCurrentTimerLabel.font.withSize(10)
        self.controlTimeToLiveLabel.font = self.controlTimeToLiveLabel.font.withSize(10)
        self.setupLiveConstraints()
    }

    private func setVodView() {
        self.setupVodEvents()
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

        // Subtitle
        self.controlSliderView.addSubview(self.subtitleButton)
        self.subtitleButton.addTarget(self, action: #selector(self.toggleSubtitleView), for: .touchUpInside)

        // Timer Label
        self.controlSliderView.addSubview(self.controlTimerLabel)
        self.controlTimerLabel.textColor = UIColor.white

        self.setupVodConstraints()
    }

    private func setupGeneralEvents() {
        self.events.didPlay = { () in
            self.setPlayBtnIcon(iconName: "pause-primary")
        }
        self.events.didPause = { () in
            self.setPlayBtnIcon(iconName: "play-primary")
        }

        self.events.didPrepare = { () in
            if self.playerController.hasSubtitles {
                DispatchQueue.main.async {
                    self.timerLeadingConstraintWithoutSubtitleButton?.isActive = false
                    self.timerLeadingConstraintWithSubtitleButton?.isActive = true
                    self.subtitleButton.isHidden = false
                }
            }
        }
    }

    private func setupVodEvents() {
        self.events.didEnd = { () in
            self.setPlayBtnIcon(iconName: "replay-primary")
        }
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

    let fullScreenButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
        btn.tintColor = .white
        return btn
    }()

    let controlSliderView: UIView = {
        let view = UIView()
        return view
    }()

    let controlSlider: UISlider = {
        let slider = UISlider()
        return slider
    }()

    let controlTimerLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    //    Timers for live
    let controlLiveCurrentTimerLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    let controlTimeToLiveLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    let subtitleButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "text.bubble"), for: .normal)
        btn.tintColor = .white
        btn.isHidden = true
        return btn
    }()

    let liveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = .white
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

        if #available(tvOS 13.0, *) {
            btn.setImage(
                UIImage(named: "live-primary", in: ApiVideoPlayerResources.resourceBundle, compatibleWith: nil),
                for: .normal
            )
        } else {
            // Fallback on earlier versions
        }
        return btn
    }()

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

    private func resetTimer() {
        self.timer?.invalidate()
        self.timer = nil
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
        if !self.playerController.isPlaying {
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
    func goToFullScreenAction() {
        guard let vc = viewController else {
            return
        }
        self.playerController.goToFullScreen(viewController: vc)
    }

    @objc
    func hideControlsHandler() {
        self.hideControls()
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

    private var sliderDidPauseVideo = false

    @objc
    func playbackSliderValueChanged(slider: UISlider, event: UIEvent) {
        self.resetTimer()
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                // handle drag began
                if self.playerController.isPlaying {
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

    @objc
    func toggleSubtitleView() {
        self.resetTimer()
        let posX = self.subtitleButton.frame.origin.x - 120
        let posY = frame.height - self.controlSliderView.frame.height - 45

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

    private func setLiveButtonTintColor(isLive: Bool) {
        if isLive {
            self.liveButton.tintColor = .red
        } else {
            self.liveButton.tintColor = .white
        }
    }

    @objc
    func goToLive() {
        self.playerController.seek(to: self.playerController.duration)
        self.setLiveButtonTintColor(isLive: true)
    }

    private func showControls() {
        self.playPauseButton.isHidden = false
        if self.videoOptions.videoType == .vod {
            self.vodControlGoForward15Button.isHidden = false
            self.vodControlGoBackward15Button.isHidden = false
        }
        self.controlSliderView.isHidden = false
        self.fullScreenButton.isHidden = false
    }

    private func hideControls() {
        self.playPauseButton.isHidden = true
        if self.videoOptions.videoType == .vod {
            self.vodControlGoForward15Button.isHidden = true
            self.vodControlGoBackward15Button.isHidden = true
        }
        self.controlSliderView.isHidden = true
        self.fullScreenButton.isHidden = true
    }

    private func updateTiming() {
        let currentTime = self.playerController.currentTime
        let duration = self.playerController.duration
        let remainingTime = duration - currentTime

        if self.videoOptions.videoType == .vod {
            self.controlSlider.value = Float(currentTime.roundedSeconds / duration.roundedSeconds)
            self.controlTimerLabel.text = remainingTime.prettyTime
        } else {
            var timeToLive = remainingTime.prettyTime
            if remainingTime > CMTime(seconds: 0.0, preferredTimescale: 1_000) {
                timeToLive = "-\(timeToLive)"
            } else {
                timeToLive = CMTime(seconds: 0.0, preferredTimescale: 1_000).prettyTime
            }
            if remainingTime >= CMTime(seconds: 3, preferredTimescale: 1_000) {
                self.setLiveButtonTintColor(isLive: false)
            } else {
                self.setLiveButtonTintColor(isLive: true)
            }
            self.controlSlider.value = Float(currentTime.roundedSeconds / duration.roundedSeconds)
            self.controlLiveCurrentTimerLabel.text = currentTime.prettyTime
            self.controlTimeToLiveLabel.text = timeToLive
        }
    }
}
#endif
