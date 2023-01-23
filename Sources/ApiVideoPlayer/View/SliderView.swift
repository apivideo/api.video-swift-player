#if !os(macOS)
import AVFoundation
import Foundation
import UIKit
class SliderView: UIView {
    private let playerController: ApiVideoPlayerController
    private let videoOptions: VideoOptions
    private var subtitleView: SubtitleView?
    private var timerLeadingConstraintWithSubtitleButton: NSLayoutConstraint?
    private var timerLeadingConstraintWithoutSubtitleButton: NSLayoutConstraint?
    private let events = PlayerEvents()
    private var timer = SharedTimer.shared
    private var sliderDidPauseVideo = false

    init(frame: CGRect, playerController: ApiVideoPlayerController, videoOptions: VideoOptions) {
        self.playerController = playerController
        self.videoOptions = videoOptions
        super.init(frame: frame)
        playerController.setTimerObserver(callback: { () in
            self.updateTiming()
        })
        self.backgroundColor = UIColor.darkGray.withAlphaComponent(0.25)

        addSubview(self.controlSlider)
        self.controlSlider.addTarget(
            self,
            action: #selector(self.playbackSliderValueChanged),
            for: .valueChanged
        )
        self.controlSlider.tintColor = UIColor.orange.withAlphaComponent(0.7)
        self.controlSlider.thumbTintColor = UIColor.white

        if videoOptions.videoType == .vod {
            self.setUpVod()
        } else {
            self.setUpLive()
        }

        self.events.didReady = { () in
            if self.playerController.hasSubtitles {
                DispatchQueue.main.async {
                    self.timerLeadingConstraintWithoutSubtitleButton?.isActive = false
                    self.timerLeadingConstraintWithSubtitleButton?.isActive = true
                    self.subtitleButton.isHidden = false
                }
            }
        }

        playerController.addEvents(events: self.events)
        self.setUpGeneralConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpVod() {

        // Subtitle
        addSubview(self.subtitleButton)
        self.subtitleButton.addTarget(self, action: #selector(self.toggleSubtitleView), for: .touchUpInside)
        
        // Timer Label
        addSubview(self.controlTimerLabel)
        self.controlTimerLabel.textColor = UIColor.white
        self.setUpVodConstraints()
    }

    private func setUpLive() {
        self.addSubview(self.liveButton)
        self.addSubview(self.controlLiveCurrentTimerLabel)
        self.addSubview(self.controlTimeToLiveLabel)

        self.liveButton.addTarget(self, action: #selector(self.goToLive), for: .touchUpInside)
        self.controlLiveCurrentTimerLabel.text = "00:00"
        self.controlTimeToLiveLabel.text = "00:00"

        self.controlLiveCurrentTimerLabel.font = self.controlLiveCurrentTimerLabel.font.withSize(10)
        self.controlTimeToLiveLabel.font = self.controlTimeToLiveLabel.font.withSize(10)
        self.setUpLiveContraints()
    }

    private func setUpGeneralConstraints() {
        // Slider
        self.controlSlider.translatesAutoresizingMaskIntoConstraints = false
        self.controlSlider.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            .isActive = true
        self.controlSlider.leadingAnchor.constraint(
            equalTo: self.leadingAnchor,
            constant: 10
        ).isActive = true
    }

    private func setUpVodConstraints() {
        // Slider right anchor
        self.controlSlider.rightAnchor.constraint(equalTo: self.controlTimerLabel.leftAnchor, constant: -10)
            .isActive = true

        // Timer Label
        self.controlTimerLabel.translatesAutoresizingMaskIntoConstraints = false
        self.controlTimerLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            .isActive = true

        self.timerLeadingConstraintWithSubtitleButton = self.controlTimerLabel.trailingAnchor.constraint(
            equalTo: self.subtitleButton.leadingAnchor,
            constant: -10
        )
        self.timerLeadingConstraintWithoutSubtitleButton = self.controlTimerLabel.rightAnchor.constraint(
            equalTo: self.rightAnchor,
            constant: -10
        )
        self.timerLeadingConstraintWithoutSubtitleButton?.isActive = true

        // subtitle
        self.subtitleButton.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            .isActive = true
        self.subtitleButton.trailingAnchor.constraint(
            equalTo: self.trailingAnchor,
            constant: -10
        ).isActive = true

    }

    private func setUpLiveContraints() {
        // Slider right anchor
        self.controlSlider.rightAnchor.constraint(equalTo: self.liveButton.leftAnchor, constant: -10)
            .isActive = true

        self.liveButton.translatesAutoresizingMaskIntoConstraints = false
        self.liveButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            .isActive = true
        self.liveButton.rightAnchor.constraint(
            equalTo: self.rightAnchor,
            constant: -10
        ).isActive = true

        self.liveButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        self.liveButton.heightAnchor.constraint(equalToConstant: 25).isActive = true

        self.controlLiveCurrentTimerLabel.translatesAutoresizingMaskIntoConstraints = false
        self.controlLiveCurrentTimerLabel.topAnchor.constraint(equalTo: self.controlSlider.bottomAnchor)
            .isActive = true
        self.controlLiveCurrentTimerLabel.leadingAnchor.constraint(
            equalTo: self.leadingAnchor,
            constant: 10
        ).isActive = true

        self.controlTimeToLiveLabel.translatesAutoresizingMaskIntoConstraints = false
        self.controlTimeToLiveLabel.centerXAnchor.constraint(equalTo: self.liveButton.centerXAnchor)
            .isActive = true
        self.controlTimeToLiveLabel.topAnchor.constraint(equalTo: self.liveButton.bottomAnchor).isActive = true

    }

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

    @objc
    func goToLive() {
        self.playerController.seek(to: self.playerController.duration)
        self.setLiveButtonTintColor(isLive: true)
    }

    @objc
    func playbackSliderValueChanged(slider: UISlider, event: UIEvent) {
        self.timer.resetTimer()
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
        self.timer.activateTimer()
    }

    @objc
    func toggleSubtitleView() {
        self.timer.resetTimer()
        let posX = self.subtitleButton.frame.origin.x - 100
        let posY = frame.height - self.frame.height - 40

        if let subtitleView = subtitleView,
           subtitleView.isDescendant(of: self)
        {
            subtitleView.dismissView()
        } else {
            subtitleView = {
                let subtitleView = SubtitleView(
                    frame: CGRect(x: posX, y: posY, width: 130, height: 3 * 45),
                    playerController: self.playerController
                )
//                let window = UIApplication.shared.windows.last
//                window!.addSubview(subtitleView)
                addSubview(subtitleView)
                bringSubviewToFront(subtitleView)
                return subtitleView
            }()
        }
        self.timer.activateTimer()
    }

    private func setLiveButtonTintColor(isLive: Bool) {
        if isLive {
            self.liveButton.tintColor = .red
        } else {
            self.liveButton.tintColor = .white
        }
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

    func dismissSubtitleView() {
        self.subtitleView?.dismissView()
    }

}
#endif
