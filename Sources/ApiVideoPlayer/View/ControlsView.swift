#if !os(macOS)
import AVFoundation
import Foundation
import UIKit

class ControlsView: UIView, UIGestureRecognizerDelegate {
    private let playerController: ApiVideoPlayerController
    private let videoOptions: VideoOptions
    private var timer = SharedTimer.shared
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
    private var sliderView: SliderView?

    init(frame: CGRect, playerController: ApiVideoPlayerController, videoOptions: VideoOptions) {
        self.playerController = playerController
        self.videoOptions = videoOptions
        super.init(frame: frame)
        self.sliderView = SliderView(
            frame: CGRect(x: 0, y: 0, width: frame.width, height: 50),
            playerController: playerController,
            videoOptions: videoOptions
        )
        self.setGenericButtons()
        if videoOptions.videoType == .vod {
            self.setVodView()
        } else {
            self.setLiveView()
        }
        self.setupGeneralEvents()
        self.timer.didTimerActivated = { () in
            self.hideControls()
        }
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
        // TODO: add sliderview
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
    }

    private func setupLiveConstraints() {
        // sliderview height
        self.sliderView?.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }

    private func setLiveView() {
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
        self.setupVodConstraints()
    }

    private func setupGeneralEvents() {
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
        self.timer.resetTimer()
        self.showControls()
        self.timer.activateTimer()

        self.sliderView?.dismissSubtitleView()
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
        if self.videoOptions.videoType == .vod {
            self.vodControlGoForward15Button.isHidden = false
            self.vodControlGoBackward15Button.isHidden = false
        }
        self.sliderView?.isHidden = false
        self.fullScreenButton.isHidden = false
    }

    private func hideControls() {
        self.playPauseButton.isHidden = true
        if self.videoOptions.videoType == .vod {
            self.vodControlGoForward15Button.isHidden = true
            self.vodControlGoBackward15Button.isHidden = true
        }
        self.sliderView?.isHidden = true
        self.fullScreenButton.isHidden = true
    }
}
#endif
