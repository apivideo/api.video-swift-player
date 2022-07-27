#if !os(macOS)
    import AVFoundation
    import Foundation
    import UIKit

    @available(iOS 14.0, *)
    class VodControlsView: UIView {
        private var timer: Timer?
        private let playerController: ApiVideoPlayerController
        private var pView: UIView!
        private var isSubtitleViewDisplay = false
        private var subtitleView: SubtitleView!
        private var timeObserver: Any?
        private var fromCMTime: CMTime!
        public var viewController: UIViewController!
        private let events = PlayerEvents()

        init(frame: CGRect, parentView: UIView, playerController: ApiVideoPlayerController) {
            self.playerController = playerController
            pView = parentView
            super.init(frame: frame)
            setVodControls()

            playerController.setTimerObserver(callback: { () in
                self.updateTiming()
            })

            events.didPlay = { () in
                self.getIconPlayBtn()
            }
            events.didPause = { () in
                self.getIconPlayBtn()
            }
            playerController.addEvents(events: events)
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
            return btn
        }()

        @available(iOS 14.0, *)
        private func setVodControls() {
            // Controls View
            pView.addSubview(self)

            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            addGestureRecognizer(tap)
            isUserInteractionEnabled = true

            // Play Pause Button
            addSubview(playPauseButton)
            playPauseButton.addTarget(self, action: #selector(playPauseAction), for: .touchUpInside)
            getIconPlayBtn()

            // Go Forward Button
            addSubview(vodControlGoForward15Button)
            vodControlGoForward15Button.addTarget(self, action: #selector(goForward15Action), for: .touchUpInside)

            // Go Backward Button
            addSubview(vodControlGoBackward15Button)
            vodControlGoBackward15Button.addTarget(self, action: #selector(goBackward15Action), for: .touchUpInside)

            // Slider View
            addSubview(vodControlSliderView)
            vodControlSliderView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.25)

            // Slider
            vodControlSliderView.addSubview(vodControlSlider)
            vodControlSlider.addTarget(self, action: #selector(playbackSliderValueChanged), for: .valueChanged)
            vodControlSlider.tintColor = UIColor.orange.withAlphaComponent(0.7)
            vodControlSlider.thumbTintColor = UIColor.white

            // Timer Label
            vodControlSliderView.addSubview(vodControlTimerLabel)
            vodControlTimerLabel.textColor = UIColor.white

            // Subtitle
            vodControlSliderView.addSubview(subtitleButton)
            subtitleButton.addTarget(self, action: #selector(displaySubtitle), for: .touchUpInside)

            // Full Screen Button
            addSubview(fullScreenButton)
            fullScreenButton.addTarget(self, action: #selector(goToFullScreenAction), for: .touchUpInside)

            setVodControlConstraints()
            activateTimer()
        }

        private func setVodControlConstraints() {
            // Controls View
            translatesAutoresizingMaskIntoConstraints = false
            topAnchor.constraint(equalTo: pView.topAnchor).isActive = true
            leadingAnchor.constraint(equalTo: pView.leadingAnchor).isActive = true
            trailingAnchor.constraint(equalTo: pView.trailingAnchor).isActive = true
            bottomAnchor.constraint(equalTo: pView.bottomAnchor).isActive = true

            // Play Pause Button
            playPauseButton.translatesAutoresizingMaskIntoConstraints = false
            playPauseButton.centerXAnchor.constraint(equalTo: pView.centerXAnchor).isActive = true
            playPauseButton.centerYAnchor.constraint(equalTo: pView.centerYAnchor).isActive = true
            playPauseButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
            playPauseButton.heightAnchor.constraint(equalToConstant: 70).isActive = true

            // Go Forward Button
            vodControlGoForward15Button.translatesAutoresizingMaskIntoConstraints = false
            vodControlGoForward15Button.centerYAnchor.constraint(equalTo: pView.centerYAnchor).isActive = true
            vodControlGoForward15Button.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: frame.width / 16).isActive = true
            vodControlGoForward15Button.widthAnchor.constraint(equalToConstant: 70).isActive = true
            vodControlGoForward15Button.heightAnchor.constraint(equalToConstant: 40).isActive = true

            // Go Backward Button
            vodControlGoBackward15Button.translatesAutoresizingMaskIntoConstraints = false
            vodControlGoBackward15Button.centerYAnchor.constraint(equalTo: pView.centerYAnchor).isActive = true
            vodControlGoBackward15Button.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -(frame.width / 16)).isActive = true
            vodControlGoBackward15Button.widthAnchor.constraint(equalToConstant: 70).isActive = true
            vodControlGoBackward15Button.heightAnchor.constraint(equalToConstant: 40).isActive = true

            // Slider View
            vodControlSliderView.translatesAutoresizingMaskIntoConstraints = false
            vodControlSliderView.centerXAnchor.constraint(equalTo: pView.centerXAnchor).isActive = true
            vodControlSliderView.trailingAnchor.constraint(equalTo: pView.trailingAnchor).isActive = true
            vodControlSliderView.leadingAnchor.constraint(equalTo: pView.leadingAnchor).isActive = true
            vodControlSliderView.bottomAnchor.constraint(equalTo: pView.bottomAnchor, constant: -12).isActive = true
            vodControlSliderView.heightAnchor.constraint(equalToConstant: pView.frame.height / 4).isActive = true

            // Slider
            vodControlSlider.translatesAutoresizingMaskIntoConstraints = false
            vodControlSlider.centerYAnchor.constraint(equalTo: vodControlSliderView.centerYAnchor).isActive = true
            vodControlSlider.leadingAnchor.constraint(equalTo: vodControlSliderView.leadingAnchor, constant: 10).isActive = true
            vodControlSlider.rightAnchor.constraint(equalTo: vodControlTimerLabel.leftAnchor, constant: -10).isActive = true

            // Timer Label
            vodControlTimerLabel.translatesAutoresizingMaskIntoConstraints = false
            vodControlTimerLabel.centerYAnchor.constraint(equalTo: vodControlSliderView.centerYAnchor).isActive = true
            vodControlTimerLabel.trailingAnchor.constraint(equalTo: subtitleButton.leadingAnchor, constant: -10).isActive = true

            subtitleButton.translatesAutoresizingMaskIntoConstraints = false
            subtitleButton.centerYAnchor.constraint(equalTo: vodControlSliderView.centerYAnchor).isActive = true
            subtitleButton.trailingAnchor.constraint(equalTo: vodControlSliderView.trailingAnchor, constant: -10).isActive = true

            // FullScreen Button
            fullScreenButton.translatesAutoresizingMaskIntoConstraints = false
            fullScreenButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
            fullScreenButton.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
            fullScreenButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
            fullScreenButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }

        private func hideControls() {
            playPauseButton.isHidden = true
            vodControlGoForward15Button.isHidden = true
            vodControlGoBackward15Button.isHidden = true
            vodControlSliderView.isHidden = true
            fullScreenButton.isHidden = true
        }

        private func showControls() {
            playPauseButton.isHidden = false
            vodControlGoForward15Button.isHidden = false
            vodControlGoBackward15Button.isHidden = false
            vodControlSliderView.isHidden = false
            fullScreenButton.isHidden = false
        }

        @objc func handleTap(_: UITapGestureRecognizer? = nil) {
            resetTimer()
            showControls()
            activateTimer()

            if isSubtitleViewDisplay {
                isSubtitleViewDisplay.toggle()
                subtitleView?.dismissView()
            }
        }

        @objc func playPauseAction() {
            resetTimer()
            if !playerController.isPlaying() {
                playerController.play()
            } else {
                playerController.pause()
            }
            getIconPlayBtn()
            activateTimer()
        }

        @objc func goForward15Action() {
            resetTimer()
            playerController.seek(time: 15)
            activateTimer()
        }

        @objc func goBackward15Action() {
            resetTimer()
            playerController.seek(time: -15)
            activateTimer()
        }

        @objc func goToFullScreenAction() {
            playerController.goToFullScreen(viewController: viewController)
        }

        @available(iOS 14.0, *)
        @objc func displaySubtitle() {
            let posX = subtitleButton.frame.origin.x - 120
            let posY = frame.height - vodControlSliderView.frame.height - 45

            if isSubtitleViewDisplay {
                isSubtitleViewDisplay.toggle()
                subtitleView.dismissView()
            } else {
                isSubtitleViewDisplay.toggle()
                subtitleView = SubtitleView(frame: CGRect(x: posX, y: posY, width: 130, height: 3 * 45), playerController: playerController)
                subtitleView.tag = 101
                pView.addSubview(subtitleView)
            }
        }

        private func activateTimer() {
            guard timer == nil else { return }
            timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(hideControlsHandler), userInfo: nil, repeats: false)
        }

        private func resetTimer() {
            timer?.invalidate()
            timer = nil
        }

        @objc func hideControlsHandler() {
            hideControls()
        }

        private func getIconPlayBtn() {
            playPauseButton.tintColor = .white
            if !playerController.isPlaying() {
                if #available(tvOS 13.0, *) {
                    playPauseButton.setImage(UIImage(named: "play-primary", in: Bundle.module, compatibleWith: nil), for: .normal)
                } else {
                    // Fallback on earlier versions
                }
            } else {
                if #available(tvOS 13.0, *) {
                    playPauseButton.setImage(UIImage(named: "pause-primary", in: Bundle.module, compatibleWith: nil), for: .normal)
                } else {
                    // Fallback on earlier versions
                }
            }
        }

        @objc func playbackSliderValueChanged(slider: UISlider, event: UIEvent) {
            let duration = playerController.duration
            playerController.pause()

            if let touchEvent = event.allTouches?.first {
                switch touchEvent.phase {
                case .began:
                    // handle drag began
                    fromCMTime = CMTime(value: CMTimeValue(Float64(slider.value) * CMTimeGetSeconds(duration)), timescale: 1)
                case .moved:
                    // handle drag moved
                    break
                case .ended:
                    // handle drag ended
                    let value = Float64(vodControlSlider.value) * CMTimeGetSeconds(duration)
                    let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
                    playerController.seek(to: Double(CMTimeGetSeconds(seekTime)))
                    playerController.play()

                default:
                    break
                }
            }
        }

        private func updateTiming() {
            let currentTime = playerController.currentTime

            let currentTimeInSeconds = CMTimeGetSeconds(currentTime)

            let duration = playerController.duration
            if CMTIME_IS_INVALID(duration) {
                return
            }
            vodControlSlider.value = Float(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))

            // Update time remaining label
            let totalTimeInSeconds = CMTimeGetSeconds(duration)
            let remainingTimeInSeconds = totalTimeInSeconds - currentTimeInSeconds

            let mins = remainingTimeInSeconds / 60
            let secs = remainingTimeInSeconds.truncatingRemainder(dividingBy: 60)
            let timeformatter = NumberFormatter()
            timeformatter.minimumIntegerDigits = 2
            timeformatter.minimumFractionDigits = 0
            timeformatter.roundingMode = .down
            guard let minsStr = timeformatter.string(from: NSNumber(value: mins)), let secsStr = timeformatter.string(from: NSNumber(value: secs)) else {
                return
            }
            vodControlTimerLabel.text = "\(minsStr):\(secsStr)"
        }

        deinit {
            playerController.removeEvents(events: events)
            playerController.removeTimeObserver()
        }
    }
#endif
