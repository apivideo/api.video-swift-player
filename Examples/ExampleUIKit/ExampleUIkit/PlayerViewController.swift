import ApiVideoPlayer
import AVKit
import UIKit

class PlayerViewController: UIViewController {
    private var didFinish: Bool = false {
        didSet {
            replayVideo()
        }
    }

    let playerView: ApiVideoPlayerView = {
        let events = PlayerEvents(
            didPause: { () in
                print("paused")
            },
            didPlay: { () in
                print("play")
            },
            didReplay: { () in
                print("video replayed")
            },
            didLoop: { () in
                print("video replayed from loop")
            },
            didSetVolume: { volume in
                print("volume set to : \(volume)")
            },
            didSeek: { from, to in
                print("seek from : \(from), to: \(to)")
            },
            didError: { error in
                print("error \(error)")
            }
        )

        return ApiVideoPlayerView(frame: .zero, videoId: "YOUR_VIDEO_ID", videoType: VideoType.vod /* only .vod is supported */, events: events)
    }()

    let scrollView: UIScrollView = {
        let scrlview = UIScrollView()
        return scrlview
    }()

    let vStack: UIStackView = {
        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.distribution = .fillEqually
        vStack.alignment = .fill
        return vStack
    }()

    let hStackFirst: UIStackView = {
        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.distribution = .fillEqually
        hStack.alignment = .center
        return hStack
    }()

    let hStackSecond: UIStackView = {
        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.distribution = .fillEqually
        hStack.alignment = .fill
        return hStack
    }()

    let hStackLast: UIStackView = {
        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.distribution = .fillEqually
        hStack.alignment = .fill
        return hStack
    }()

    let pauseButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Pause", for: .normal)
        btn.sizeToFit()
        return btn
    }()

    let playButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Play", for: .normal)
        btn.sizeToFit()
        return btn
    }()

    let replayButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Replay", for: .normal)
        btn.sizeToFit()
        return btn
    }()

    let fullscreenButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("FullScreen", for: .normal)
        btn.sizeToFit()
        return btn
    }()

    let muteButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Mute", for: .normal)
        btn.sizeToFit()
        return btn
    }()

    let unmuteButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Unmute", for: .normal)
        btn.sizeToFit()
        return btn
    }()

    let goForwardButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Seek +15s", for: .normal)
        btn.sizeToFit()
        return btn
    }()

    let goBackwardButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Seek -15s", for: .normal)
        btn.sizeToFit()
        return btn
    }()

    let hideControlsButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Hide Controls", for: .normal)
        btn.sizeToFit()
        return btn
    }()

    let frSubtitleButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("French Subtitle", for: .normal)
        btn.sizeToFit()
        return btn
    }()

    let turnOffSubtitleButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Turn Off Subtitle", for: .normal)
        btn.sizeToFit()
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.addSubview(playerView)

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        playerView.addGestureRecognizer(doubleTap)

        let swipeGestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        swipeGestureRecognizerRight.direction = .right
        playerView.addGestureRecognizer(swipeGestureRecognizerRight)
        scrollView.addSubview(vStack)
        vStack.addArrangedSubview(hStackFirst)
        vStack.addArrangedSubview(hStackSecond)
        vStack.addArrangedSubview(hStackLast)

        hStackFirst.addArrangedSubview(pauseButton)
        pauseButton.addTarget(self, action: #selector(pauseAction), for: .touchUpInside)

        hStackFirst.addArrangedSubview(playButton)
        playButton.addTarget(self, action: #selector(playAction), for: .touchUpInside)

        hStackFirst.addArrangedSubview(replayButton)
        replayButton.addTarget(self, action: #selector(replayAction), for: .touchUpInside)

        hStackFirst.addArrangedSubview(fullscreenButton)
        fullscreenButton.addTarget(self, action: #selector(fullscreenAction), for: .touchUpInside)

        hStackSecond.addArrangedSubview(muteButton)
        muteButton.addTarget(self, action: #selector(muteAction), for: .touchUpInside)

        hStackSecond.addArrangedSubview(unmuteButton)
        unmuteButton.addTarget(self, action: #selector(unmuteAction), for: .touchUpInside)

        hStackSecond.addArrangedSubview(goForwardButton)
        goForwardButton.addTarget(self, action: #selector(forwardAction), for: .touchUpInside)

        hStackSecond.addArrangedSubview(goBackwardButton)
        goBackwardButton.addTarget(self, action: #selector(backwardAction), for: .touchUpInside)

        hStackLast.addArrangedSubview(hideControlsButton)
        hideControlsButton.addTarget(self, action: #selector(hideControlsAction), for: .touchUpInside)

        hStackLast.addArrangedSubview(frSubtitleButton)
        frSubtitleButton.addTarget(self, action: #selector(frSubtitleAction), for: .touchUpInside)

        hStackLast.addArrangedSubview(turnOffSubtitleButton)
        turnOffSubtitleButton.addTarget(self, action: #selector(turnOffSubtitleAction), for: .touchUpInside)

        constraints()
    }

    private func replayVideo() {
        playerView.replay()
    }

    override func viewDidAppear(_: Bool) {
        playerView.viewController = self
    }

    private func constraints() {
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true

        // PlayerView
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        playerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0).isActive = true
        playerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16.0).isActive = true
        playerView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.height * 0.3).isActive = true

        // Main VStack
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.topAnchor.constraint(equalTo: playerView.bottomAnchor, constant: 20).isActive = true
        vStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16.0).isActive = true
        vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
        vStack.heightAnchor.constraint(equalToConstant: 220).isActive = true
        vStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16).isActive = true
    }

    @objc func pauseAction(sender _: UIButton!) {
        playerView.pause()
    }

    @objc func playAction(sender _: UIButton!) {
        playerView.play()
    }

    @objc func replayAction(sender _: UIButton!) {
        playerView.replay()
    }

    @objc func fullscreenAction(sender _: UIButton!) {
        playerView.goToFullScreen()
    }

    @objc func muteAction(sender _: UIButton!) {
        playerView.isMuted = true
    }

    @objc func unmuteAction(sender _: UIButton!) {
        playerView.isMuted = false
    }

    @objc func forwardAction(sender _: UIButton!) {
        playerView.seek(offset: 15)
    }

    @objc func backwardAction(sender _: UIButton!) {
        playerView.seek(offset: -15)
    }

    @objc func hideControlsAction(sender _: UIButton!) {
        playerView.hideControls()
    }

    @objc func frSubtitleAction(sender _: UIButton!) {
        playerView.currentSubtitle = Locale(identifier: "fr")
    }

    @objc func turnOffSubtitleAction(sender _: UIButton!) {
        playerView.hideSubtitle()
    }

    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer? = nil) {
        let viewCenterPosition = view.frame.width / 2
        let touchPoint = sender!.location(in: view)
        if touchPoint.x < viewCenterPosition {
            playerView.seek(offset: -15)
        } else {
            playerView.seek(offset: 15)
        }
    }

    @objc private func didSwipe(_: UISwipeGestureRecognizer) {
        playerView.goToFullScreen()
    }
}
