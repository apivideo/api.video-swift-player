#if !os(macOS)
import AVFoundation
import Foundation
import UIKit

class ActionBarView: UIView {
    public weak var delegate: ActionBarViewDelegate?

    private let timeSliderView: TimeSliderView
    private let playerController: ApiVideoPlayerController

    private var timeObserver: Any?

    private var verticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 1
        return stack
    }()

    private let bottomActionView: UIView = {
        let view = UIView()
        view.sizeToFit()
        view.isHidden = true
        return view
    }()

    private let actionStackView: UIStackView = {
        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.spacing = 10
        hStack.distribution = .fillEqually
        hStack.alignment = .center
        return hStack
    }()

    private let subtitleButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "text.bubble"), for: .normal)
        btn.tintColor = .white
        btn.isHidden = true
        btn.sizeToFit()
        return btn
    }()

    private let speedometerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "speedometer"), for: .normal)
        btn.tintColor = .white
        btn.sizeToFit()
        return btn
    }()

    private let liveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = .white
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.setImage(
            UIImage(named: "live-primary", in: ApiVideoPlayerResources.resourceBundle, compatibleWith: nil),
            for: .normal
        )
        btn.isHidden = true
        return btn
    }()

    private var sliderDidPauseVideo = false

    init(frame: CGRect, playerController: ApiVideoPlayerController) {
        self.playerController = playerController

        timeSliderView = TimeSliderView(frame: frame)

        timeSliderView.sizeToFit()

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
        addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(timeSliderView)
        verticalStackView.addArrangedSubview(bottomActionView)

        bottomActionView.addSubview(actionStackView)
        actionStackView.addArrangedSubview(subtitleButton)
        actionStackView.addArrangedSubview(speedometerButton)
        bottomActionView.addSubview(liveButton)

        liveButton.addTarget(self, action: #selector(goToLive), for: .touchUpInside)
        subtitleButton.addTarget(self, action: #selector(self.toggleSubtitleView), for: .touchUpInside)
        speedometerButton.addTarget(self, action: #selector(self.toggleSpeedometerView), for: .touchUpInside)

        addConstraints()
    }

    func addConstraints() {

        // StackView
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        verticalStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 6).isActive = true
        verticalStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -6).isActive = true

        actionStackView.translatesAutoresizingMaskIntoConstraints = false
        actionStackView.leftAnchor.constraint(equalTo: bottomActionView.leftAnchor).isActive = true
        actionStackView.topAnchor.constraint(equalTo: bottomActionView.topAnchor).isActive = true
        actionStackView.bottomAnchor.constraint(equalTo: bottomActionView.bottomAnchor).isActive = true

        // LiveButton
        liveButton.translatesAutoresizingMaskIntoConstraints = false
        liveButton.rightAnchor.constraint(equalTo: bottomActionView.rightAnchor).isActive = true
        liveButton.centerYAnchor.constraint(equalTo: bottomActionView.centerYAnchor).isActive = true
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

    @objc
    private func toggleSubtitleView() {
        delegate?.subtitleButtonTapped(subtitleButton: subtitleButton)
    }

    @objc
    private func toggleSpeedometerView() {
        delegate?.speedometerButtonTapped(speedometerButton: speedometerButton)
    }
}

extension ActionBarView: ApiVideoPlayerControllerPlayerDelegate {
    func didPrepare() {}

    func didReady() {
        // Reset time slider
        timeSliderView.duration = playerController.duration
        timeSliderView.currentTime = playerController.currentTime

        // Show or hide live button
        liveButton.isHidden = !playerController.isLive

        // Show or hide subtitle button
        subtitleButton.isHidden = !playerController.hasSubtitles

        // Show or hide bottomActionView if there is no button inside
        bottomActionView.isHidden = liveButton.isHidden && !actionStackView.hasVisibleItems
    }

    func didPause() {
        removeTimeObserver()
    }

    func didPlay() {
        timeObserver = playerController.addTimerObserver(callback: { () in
            self.updateLiveButtonColor()
            if self.playerController.isLive {
                self.timeSliderView.duration = self.playerController.duration
            }
            self.timeSliderView.currentTime = self.playerController.currentTime
        })
    }

    func didReplay() {}

    func didMute() {}

    func didUnMute() {}

    func didLoop() {}

    func didSetVolume(_: Float) {}

    func didSeek(_: CMTime, _: CMTime) {
        timeSliderView.currentTime = playerController.currentTime
        updateLiveButtonColor()
    }

    func didEnd() {
        removeTimeObserver()
    }

    func didError(_: Error) {}

    func didVideoSizeChanged(_: CGSize) {}
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
    func speedometerButtonTapped(speedometerButton: UIButton)
    func sliderValueChangedDidStart(position: Float64)
    func sliderValueChangedDidMove(position: Float64)
    func sliderValueChangedDidStop(position: Float64)
}

#endif
