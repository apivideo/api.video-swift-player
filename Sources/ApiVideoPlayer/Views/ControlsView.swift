#if !os(macOS)
import AVFoundation
import Foundation
import UIKit

class ControlsView: UIView {
    private let playerController: ApiVideoPlayerController

    private let actionBarView: ActionBarView
    private let timer = ScheduledTimer()

    private var subtitleView: SelectableListView<SubtitleLanguage>?
    private var speedometerView: SelectableListView<Float>?

    public var viewController: UIViewController? {
        didSet {
            if viewController != nil {
                fullScreenButton.isHidden = false
            } else {
                fullScreenButton.isHidden = true
            }
        }
    }

    private let tapView: UIView = {
        let view = UIView()
        return view
    }()

    private let playPauseButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = .white
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return btn
    }()

    private let forward15Button: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(name: "goforward.15")
        btn.tintColor = .white
        return btn
    }()

    private let backward15Button: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(name: "gobackward.15")
        btn.tintColor = .white
        return btn
    }()

    private let fullScreenButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(name: "arrow.up.left.and.arrow.down.right")
        btn.tintColor = .white
        return btn
    }()

    required init(frame: CGRect, playerController: ApiVideoPlayerController) {
        self.playerController = playerController

        actionBarView = ActionBarView(frame: frame, playerController: playerController)

        super.init(frame: frame)

        // Add delegates
        timer.delegate = self
        actionBarView.delegate = self
        self.playerController.addDelegate(delegate: self)

        // Add subviews
        addSubview()

        // Hide view in few seconds
        timer.activate()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        playerController.removeDelegate(delegate: self)
    }

    private func addSubview() {
        addSubview(tapView)
        addSubview(fullScreenButton)
        addSubview(playPauseButton)
        addSubview(forward15Button)
        addSubview(backward15Button)

        addSubview(actionBarView)

        addActions()
        addConstraints()
    }

    private func addActions() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapView.addGestureRecognizer(tapGestureRecognizer)
        tapView.isUserInteractionEnabled = true

        fullScreenButton.addTarget(self, action: #selector(goToFullScreenAction), for: .touchUpInside)
        fullScreenButton.isHidden = true

        // Play/Pause button
        playPauseButton.addTarget(self, action: #selector(playPauseAction), for: .touchUpInside)
        setPlayBtnIcon(iconName: "play-primary")

        // Forward Button
        forward15Button.addTarget(
            self,
            action: #selector(goForward15Action),
            for: .touchUpInside
        )

        // Backward Button
        backward15Button.addTarget(
            self,
            action: #selector(goBackward15Action),
            for: .touchUpInside
        )
    }

    private func addConstraints() {
        tapView.translatesAutoresizingMaskIntoConstraints = false
        tapView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tapView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        tapView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        tapView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        // FullScreen Button
        fullScreenButton.translatesAutoresizingMaskIntoConstraints = false
        fullScreenButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        fullScreenButton.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        fullScreenButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        fullScreenButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

        // Play Pause Button
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        playPauseButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        playPauseButton.heightAnchor.constraint(equalToConstant: 70).isActive = true

        // Forward Button
        forward15Button.translatesAutoresizingMaskIntoConstraints = false
        forward15Button.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        forward15Button.leftAnchor.constraint(
            equalTo: playPauseButton.rightAnchor,
            constant: frame.width / 16
        ).isActive = true
        forward15Button.widthAnchor.constraint(equalToConstant: 70).isActive = true
        forward15Button.heightAnchor.constraint(equalToConstant: 40).isActive = true

        // Backward Button
        backward15Button.translatesAutoresizingMaskIntoConstraints = false
        backward15Button.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        backward15Button.rightAnchor.constraint(
            equalTo: playPauseButton.leftAnchor,
            constant: -(frame.width / 16)
        ).isActive = true
        backward15Button.widthAnchor.constraint(equalToConstant: 70).isActive = true
        backward15Button.heightAnchor.constraint(equalToConstant: 40).isActive = true

        // Slider Views
        actionBarView.translatesAutoresizingMaskIntoConstraints = false
        actionBarView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        actionBarView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        actionBarView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        actionBarView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    private func setPlayBtnIcon(iconName: String) {
        playPauseButton.setImage(
            UIImage(named: iconName, in: ApiVideoPlayerResources.resourceBundle, compatibleWith: nil),
            for: .normal
        )
    }

    @objc
    func handleTap(_: UIGestureRecognizer) {
        removeSubtitleView()
        removeSpeedometerView()
        timer.reset {
            showControls()
        }
    }

    private func removeSubtitleView() {
        subtitleView?.removeFromSuperview()
        subtitleView = nil
    }

    private func removeSpeedometerView() {
        speedometerView?.removeFromSuperview()
        speedometerView = nil
    }

    @objc
    func playPauseAction() {
        timer.reset {
            if !playerController.isPlaying {
                // Detects end of playing
                if playerController.isAtEnd {
                    playerController.replay()
                } else {
                    playerController.play()
                }
            } else {
                playerController.pause()
            }
        }
    }

    @objc
    func goToFullScreenAction() {
        guard let viewController = viewController else {
            return
        }
        playerController.goToFullScreen(viewController: viewController)
    }

    @objc
    func goForward15Action() {
        timer.reset {
            playerController.seek(offset: CMTime(seconds: 15, preferredTimescale: 1_000))
        }
    }

    @objc
    func goBackward15Action() {
        timer.reset {
            if playerController.isAtEnd {
                setPlayBtnIcon(iconName: "play-primary")
            }
            playerController.seek(offset: CMTime(seconds: -15, preferredTimescale: 1_000))
            timer.activate()
        }
    }

    private func showHideControls(_ isHidden: Bool) {
        playPauseButton.isHidden = isHidden
        forward15Button.isHidden = isHidden
        backward15Button.isHidden = isHidden
        actionBarView.isHidden = isHidden
        fullScreenButton.isHidden = isHidden
        if isHidden {
            removeSubtitleView()
            removeSpeedometerView()
        }
    }

    private func showControls() {
        showHideControls(false)
    }

    private func hideControls() {
        showHideControls(true)
    }
}

extension ControlsView: ApiVideoPlayerControllerPlayerDelegate {
    func didPrepare() {}

    func didReady() {
        // remove subtitle view if it is present when loading another video to force user to reload it
        removeSubtitleView()
        removeSpeedometerView()
    }

    func didPause() {
        setPlayBtnIcon(iconName: "play-primary")
    }

    func didPlay() {
        setPlayBtnIcon(iconName: "pause-primary")
    }

    func didReplay() {}

    func didMute() {}

    func didUnMute() {}

    func didLoop() {}

    func didSetVolume(_: Float) {}

    func didSeek(_: CMTime, _: CMTime) {}

    func didEnd() {
        if playerController.isVod {
            setPlayBtnIcon(iconName: "replay-primary")
        }
    }

    func didError(_: Error) {}

    func didVideoSizeChanged(_: CGSize) {}
}

extension ControlsView: ActionBarViewDelegate {
    private func toggleView(view: UIView) {
        if view.isDescendant(of: self) {
            view.removeFromSuperview()
        } else {
            addSubview(view)
        }
    }

    func subtitleButtonTapped(subtitleButton: UIButton) {
        timer.clear()
        let posX = subtitleButton.frame.origin.x + 6
        let posY = self.frame.height - 90

        // remove speedometerView if on screen
        removeSpeedometerView()

        // Do toggle
        if let subtitleView = subtitleView,
           subtitleView.isDescendant(of: self)
        {
            removeSubtitleView()
        } else {
            var languages: [SubtitleLanguage] = [SubtitleLanguage.off]
            playerController.subtitleLocales.forEach {
                languages.append($0.toSubtitleLanguage())
            }
            let notOptionalSubtitleView = SelectableListView(
                frame: CGRect(x: posX, y: posY, width: 130, height: 3 * 45),
                elements: languages,
                selectedElement: playerController.currentSubtitleLocale?.toSubtitleLanguage() ?? SubtitleLanguage
                    .off
            )
            notOptionalSubtitleView.delegate = self
            addSubview(notOptionalSubtitleView)
            bringSubviewToFront(notOptionalSubtitleView)
            subtitleView = notOptionalSubtitleView
        }

        timer.activate()
    }

    func speedometerButtonTapped(speedometerButton: UIButton) {
        timer.clear()
        let posX = speedometerButton.frame.origin.x + 6
        let posY = self.frame.height - 90

        // remove subtitleview if on screen
        removeSubtitleView()

        // Do toggle
        if let speedometerView = speedometerView,
           speedometerView.isDescendant(of: self)
        {
            removeSpeedometerView()
        } else {
            let notOptionalSpeedometerView = SelectableListView(
                frame: CGRect(x: posX, y: posY, width: 130, height: 3 * 45),
                elements: [0.5, 1.0, 1.25, 1.5, 2.0],
                selectedElement: playerController.speedRate
            )
            notOptionalSpeedometerView.delegate = self
            addSubview(notOptionalSpeedometerView)
            bringSubviewToFront(notOptionalSpeedometerView)
            speedometerView = notOptionalSpeedometerView
        }

        timer.activate()
    }

    func sliderValueChangedDidStart(position _: Float64) {
        timer.clear()
    }

    func sliderValueChangedDidMove(position _: Float64) {
        // Nothing to do
    }

    func sliderValueChangedDidStop(position _: Float64) {
        timer.activate()
    }
}

extension ControlsView: SelectableListViewDelegate {
    func newElementSelected(
        view: SelectableListView<some Equatable & CustomStringConvertible>,
        element: some Equatable & CustomStringConvertible
    ) {
        if view == subtitleView {
            guard let subtitleLanguage = element as? SubtitleLanguage else {
                fatalError("Subtitle language must be a SubtitleLanguage")
            }

            let locale = subtitleLanguage.toLocale()
            if let locale = locale {
                playerController.setCurrentSubtitleLocale(locale: locale)
            } else {
                playerController.hideSubtitle()
            }
            removeSubtitleView()
        } else if view == speedometerView {
            guard let speed = element as? Float else {
                fatalError("Speed rate must be a Float")
            }

            playerController.speedRate = speed
            removeSpeedometerView()
        }
    }

    func newElementSelected(element _: Any) {}
}

extension ControlsView: ScheduledTimerDelegate {
    func didTimerFire() {
        hideControls()
    }
}
#endif
