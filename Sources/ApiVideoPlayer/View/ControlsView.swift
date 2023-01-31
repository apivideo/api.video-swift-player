#if !os(macOS)
import AVFoundation
import Foundation
import UIKit

class ControlsView: UIView, UIGestureRecognizerDelegate {
    private let playerController: ApiVideoPlayerController
    private let controlsViewOptions: ControlsViewOptions
    private var timer = SharedTimer.shared
    private var timeObserver: Any?
    private var sliderDidPauseVideo = false
    private var subtitleView: SubtitleView?
    private var timerLeadingConstraintWithSubtitleButton: NSLayoutConstraint?
    private var timerLeadingConstraintWithoutSubtitleButton: NSLayoutConstraint?
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
    private var sliderView: SliderView?

    required init(frame: CGRect, playerController: ApiVideoPlayerController, controlsViewOptions: ControlsViewOptions) {
        self.playerController = playerController
        self.controlsViewOptions = controlsViewOptions
        super.init(frame: frame)
        self.sliderView = SliderView(
            frame: CGRect(x: 0, y: 0, width: frame.width, height: 50), controlsViewOptions.enableLiveButton
        )
        self.sliderView?.delegate = self
        self.setGenericButtons()

        if playerController.videoOptions?.videoType == .vod {
            self.setVodView()
        } else {
            self.setLiveView()
        }

        self.setupGeneralEvents()
        self.timer.didTimerActivated = { () in
            self.hideControls()
        }
        playerController.setTimerObserver(callback: { () in
            self.sliderView?.duration = self.playerController.duration
            self.sliderView?.currentTime = self.playerController.currentTime
        })

        playerController.addEvents(events: self.events)
        if let sliderV = self.sliderView {
            insertSubview(sliderV, aboveSubview: self)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public static func buildForLive(
        frame: CGRect,
        playerController: ApiVideoPlayerController,
        controlsViewOptions: ControlsViewOptions
    ) -> ControlsView {
        self.init(frame: frame, playerController: playerController, controlsViewOptions: controlsViewOptions)
    }

    public static func buildForVod(
        frame: CGRect,
        playerController: ApiVideoPlayerController,
        controlsViewOptions: ControlsViewOptions
    ) -> ControlsView {
        self.init(frame: frame, playerController: playerController, controlsViewOptions: controlsViewOptions)
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
        guard let view = sliderView else { return }
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

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

        // FullScreen Button
        self.fullScreenButton.translatesAutoresizingMaskIntoConstraints = false
        self.fullScreenButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        self.fullScreenButton.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        self.fullScreenButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        self.fullScreenButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }

    private func setupVodConstraints() {
        self.sliderView?.heightAnchor.constraint(equalToConstant: 50).isActive = true

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
        self.timerLeadingConstraintWithSubtitleButton = self.sliderView?.controlTimerLabel.trailingAnchor.constraint(
            equalTo: self.subtitleButton.leadingAnchor,
            constant: -10
        )
        self.timerLeadingConstraintWithoutSubtitleButton = self.sliderView?.controlTimerLabel.rightAnchor.constraint(
            equalTo: self.rightAnchor,
            constant: -10
        )
        self.timerLeadingConstraintWithoutSubtitleButton?.isActive = true

        // subtitle
        self.subtitleButton.translatesAutoresizingMaskIntoConstraints = false
        if let sliderV = self.sliderView {
            self.subtitleButton.centerYAnchor.constraint(equalTo: sliderV.centerYAnchor)
                .isActive = true
            self.subtitleButton.trailingAnchor.constraint(
                equalTo: sliderV.trailingAnchor,
                constant: -10
            ).isActive = true
        }
    }

    private func setupLiveConstraints() {
        // sliderview height
        self.sliderView?.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }

    private func setLiveView() {
        self.sliderView?.addSubview(self.subtitleButton)
        self.subtitleButton.addTarget(self, action: #selector(self.toggleSubtitleView), for: .touchUpInside)
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
        self.sliderView?.addSubview(self.subtitleButton)
        self.subtitleButton.addTarget(self, action: #selector(self.toggleSubtitleView), for: .touchUpInside)
        self.setupVodConstraints()
    }

    private func setupGeneralEvents() {
        self.events.didReady = { () in
            if self.playerController.hasSubtitles {
                self.timerLeadingConstraintWithoutSubtitleButton?.isActive = false
                self.timerLeadingConstraintWithSubtitleButton?.isActive = true
                self.subtitleButton.isHidden = false
            }
        }
        self.events.didPlay = { () in
            self.setPlayBtnIcon(iconName: "pause-primary")
        }
        self.events.didPause = { () in
            self.setPlayBtnIcon(iconName: "play-primary")
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

    let subtitleButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "text.bubble"), for: .normal)
        btn.tintColor = .white
        btn.isHidden = true
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

    @objc
    func handleTap(_: UIGestureRecognizer) {
        print("tap gesture recognised")
        self.timer.resetTimer()
        self.showControls()
        self.timer.activateTimer()
        self.dismissSubtitleView()
        self.subtitleView?.dismissView()
    }

    private func dismissSubtitleView() {
        self.subtitleView?.dismissView()
    }

    @objc
    func playPauseAction() {
        self.timer.resetTimer()
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
        self.timer.activateTimer()
    }

    @objc
    func goToFullScreenAction() {
        guard let vc = viewController else {
            return
        }
        self.playerController.goToFullScreen(viewController: vc)
    }

    @objc
    func goForward15Action() {
        self.timer.resetTimer()
        self.playerController.seek(offset: CMTime(seconds: 15, preferredTimescale: 1_000))
        self.timer.activateTimer()
    }

    @objc
    func goBackward15Action() {
        self.timer.resetTimer()
        if self.playerController.isAtEnd {
            self.setPlayBtnIcon(iconName: "play-primary")
        }
        self.playerController.seek(offset: CMTime(seconds: -15, preferredTimescale: 1_000))
        self.timer.activateTimer()
    }

    private func showControls() {
        self.playPauseButton.isHidden = false
        if self.playerController.videoOptions?.videoType == .vod {
            self.vodControlGoForward15Button.isHidden = false
            self.vodControlGoBackward15Button.isHidden = false
        }
        self.sliderView?.isHidden = false
        self.fullScreenButton.isHidden = false
    }

    private func hideControls() {
        self.playPauseButton.isHidden = true
        if self.playerController.videoOptions?.videoType == .vod {
            self.vodControlGoForward15Button.isHidden = true
            self.vodControlGoBackward15Button.isHidden = true
        }
        self.sliderView?.isHidden = true
        self.fullScreenButton.isHidden = true
        self.subtitleView?.isHidden = true
    }

    @objc
    private func toggleSubtitleView() {
        self.timer.resetTimer()
        var posX = CGFloat(0)
        var posY = CGFloat(0)
        if let sliderV = self.sliderView {
            posX = self.subtitleButton.frame.origin.x - 100
            posY = self.frame.height - sliderV.frame.height - 40
        }

        if let subtitleView = subtitleView,
           subtitleView.isDescendant(of: self)
        {
            subtitleView.dismissView()
        } else {
            subtitleView = {
                let subtitleView = SubtitleView(
                    frame: CGRect(x: posX, y: posY, width: 130, height: 3 * 45), self.playerController.subtitles
                )
                subtitleView.delegate = self
                subtitleView.selectedLanguage = self.playerController.currentSubtitle
                return subtitleView
            }()
            guard let superV = self.superview else { return }
            guard let subtitleV = subtitleView else { return }
            superV.addSubview(subtitleV)
        }
        self.timer.activateTimer()
    }
}

extension ControlsView: SliderViewDelegate, SubtitleViewDelegate {
    func goBackToLive() {
        self.playerController.seek(to: self.playerController.duration)
    }

    func sliderValueChangeDidStart(position _: Float64) {
        if self.playerController.isPlaying {
            self.playerController.pauseBeforeSeek()
            self.sliderDidPauseVideo = true
        }
    }

    func sliderValueChangeDidMove(position _: Float64) {}

    func sliderValueChangeDidStop(position: Float64) {
        let value = position * CMTimeGetSeconds(self.playerController.duration)
        self.playerController.seek(to: CMTime(seconds: value, preferredTimescale: 1_000))
        if self.sliderDidPauseVideo {
            self.playerController.play()
        }
        self.sliderDidPauseVideo = false
    }

    func addEvents(events: PlayerEvents) {
        self.playerController.addEvents(events: events)
    }

    func languageSelected(language: SubtitleLanguage) {
        self.playerController.currentSubtitle = language
    }
}
#endif
