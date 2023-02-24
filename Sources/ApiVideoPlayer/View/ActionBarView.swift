#if !os(macOS)
import AVFoundation
import Foundation
import UIKit

class ActionBarView: UIView {
    public weak var delegate: ActionBarViewDelegate?

    private let timeSliderView: TimeSliderView
    private let playerController: ApiVideoPlayerController

    private var timeObserver: Any?

    private let liveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = .white
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5) // TODO: Do not use UIEdgeInsets
        btn.setImage(
                UIImage(named: "live-primary", in: ApiVideoPlayerResources.resourceBundle, compatibleWith: nil),
                for: .normal
        )
        return btn
    }()

    private var sliderDidPauseVideo = false

    init(frame: CGRect, playerController: ApiVideoPlayerController) {
        self.playerController = playerController

        timeSliderView = TimeSliderView(frame: frame)

        super.init(frame: frame)

        timeSliderView.delegate = self
        playerController.addDelegate(delegate: self)

        backgroundColor = UIColor.darkGray.withAlphaComponent(0.25)

        addSubview()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        removeTimeObserver()
        playerController.removeDelegate(delegate: self)
    }

    func addSubview() {
        addSubview(timeSliderView)
        addSubview(liveButton)
        // addSubview() // TODO UiStackView

        bringSubviewToFront(timeSliderView)
        liveButton.addTarget(self, action: #selector(goToLive), for: .touchUpInside)

        addConstraints()
    }

    func addConstraints() {
        // TimeSliderView
        timeSliderView.translatesAutoresizingMaskIntoConstraints = false
        timeSliderView.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        timeSliderView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        timeSliderView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        // LiveButton
        liveButton.translatesAutoresizingMaskIntoConstraints = false
        liveButton.topAnchor.constraint(equalTo: timeSliderView.bottomAnchor, constant: 10).isActive = true
        liveButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        liveButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
    }

    private func updateLiveButtonColor() {
        let remainingTime = playerController.duration - playerController.currentTime
        if remainingTime >= CMTime(seconds: 3, preferredTimescale: 1_000) {
            setLiveButtonTintColor(false)
        } else {
            setLiveButtonTintColor(true)
        }
    }

    @objc
    func goToLive() {
        playerController.seek(to: playerController.duration) { completed in
            if completed {
                self.setLiveButtonTintColor(true)
            } else {
                self.setLiveButtonTintColor(false)
            }
        }
    }

    private func setLiveButtonTintColor(_ isRealTime: Bool) {
        if isRealTime {
            liveButton.tintColor = .red
        } else {
            liveButton.tintColor = .white
        }
    }

    private func removeTimeObserver() {
        if let timeObserver = timeObserver {
            playerController.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }
}

extension ActionBarView: PlayerDelegate {
    func didPrepare() {
    }

    func didReady() {
        timeSliderView.duration = playerController.duration
        if playerController.isVod {
            liveButton.isHidden = true
        } else if playerController.isLive {
            liveButton.isHidden = false
        } else {
            print("Error: unexpected video type")
        }

        // TODO: Show or hide subtitle button
        /*
        subtitleButton.isHidden = !playerController.hasSubtitles
        if playerController.hasSubtitles {
            timerLeadingConstraintWithoutSubtitleButton?.isActive = false
            timerLeadingConstraintWithSubtitleButton?.isActive = true
            subtitleButton.isHidden = false
        }
         */
    }

    func didPause() {
        removeTimeObserver()
    }

    func didPlay() {
        timeObserver = playerController.addTimerObserver(callback: { () in
            self.updateLiveButtonColor()
            self.timeSliderView.currentTime = self.playerController.currentTime
        })
    }

    func didReplay() {
    }

    func didMute() {
    }

    func didUnMute() {
    }

    func didLoop() {
    }

    func didSetVolume(_ volume: Float) {
    }

    func didSeek(_ from: CMTime, _ to: CMTime) {
        timeSliderView.currentTime = playerController.currentTime
        updateLiveButtonColor()
    }

    func didEnd() {
        removeTimeObserver()
    }

    func didError(_ error: Error) {
    }

    func didVideoSizeChanged(_ size: CGSize) {
    }
}

extension ActionBarView: TimeSliderViewDelegate {
    func sliderValueChangedDidStart(position: Float64) {
        delegate?.sliderValueChangedDidStart(position: position)
        if playerController.isPlaying {
            playerController.pauseBeforeSeek()
            sliderDidPauseVideo = true
        }
    }

    func sliderValueChangedDidMove(position: Float64) {
        delegate?.sliderValueChangedDidMove(position: position)
    }

    func sliderValueChangedDidStop(position: Float64) {
        playerController.seek(to: CMTime(seconds: position, preferredTimescale: 1_000))
        if sliderDidPauseVideo {
            playerController.play()
        }
        sliderDidPauseVideo = false
        delegate?.sliderValueChangedDidStop(position: position)
    }
}

public protocol ActionBarViewDelegate: AnyObject {
    func subtitleButtonTapped(subtitleButton: UIButton)

    func sliderValueChangedDidStart(position: Float64)
    func sliderValueChangedDidMove(position: Float64)
    func sliderValueChangedDidStop(position: Float64)
}

#endif
