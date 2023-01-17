import ApiVideoPlayer
import AVKit
import UIKit

class PlayerViewController: UIViewController {
    private var didFinish = false {
        didSet {
            self.replayVideo()
        }
    }

    let playerView: ApiVideoPlayerView = {
        let events = PlayerEvents(
            didPrepare: { () in
                print("didPrepare")
            },
            didReady: { () in
                print("didReady")
            },
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

        return ApiVideoPlayerView(
            frame: .zero,
            videoId: "YOUR_VIDEO_ID",
            videoType: VideoType.vod,
            events: events
        )
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
        view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.playerView)

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        self.playerView.addGestureRecognizer(doubleTap)

        let swipeGestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(self.didSwipe(_:)))
        swipeGestureRecognizerRight.direction = .right
        self.playerView.addGestureRecognizer(swipeGestureRecognizerRight)
        self.scrollView.addSubview(self.vStack)
        self.vStack.addArrangedSubview(self.hStackFirst)
        self.vStack.addArrangedSubview(self.hStackSecond)
        self.vStack.addArrangedSubview(self.hStackLast)

        self.hStackFirst.addArrangedSubview(self.pauseButton)
        self.pauseButton.addTarget(self, action: #selector(self.pauseAction), for: .touchUpInside)

        self.hStackFirst.addArrangedSubview(self.playButton)
        self.playButton.addTarget(self, action: #selector(self.playAction), for: .touchUpInside)

        self.hStackFirst.addArrangedSubview(self.replayButton)
        self.replayButton.addTarget(self, action: #selector(self.replayAction), for: .touchUpInside)

        self.hStackFirst.addArrangedSubview(self.fullscreenButton)
        self.fullscreenButton.addTarget(self, action: #selector(self.fullscreenAction), for: .touchUpInside)

        self.hStackSecond.addArrangedSubview(self.muteButton)
        self.muteButton.addTarget(self, action: #selector(self.muteAction), for: .touchUpInside)

        self.hStackSecond.addArrangedSubview(self.unmuteButton)
        self.unmuteButton.addTarget(self, action: #selector(self.unmuteAction), for: .touchUpInside)

        self.hStackSecond.addArrangedSubview(self.goForwardButton)
        self.goForwardButton.addTarget(self, action: #selector(self.forwardAction), for: .touchUpInside)

        self.hStackSecond.addArrangedSubview(self.goBackwardButton)
        self.goBackwardButton.addTarget(self, action: #selector(self.backwardAction), for: .touchUpInside)

        self.hStackLast.addArrangedSubview(self.hideControlsButton)
        self.hideControlsButton.addTarget(self, action: #selector(self.hideControlsAction), for: .touchUpInside)

        self.hStackLast.addArrangedSubview(self.frSubtitleButton)
        self.frSubtitleButton.addTarget(self, action: #selector(self.frSubtitleAction), for: .touchUpInside)

        self.hStackLast.addArrangedSubview(self.turnOffSubtitleButton)
        self.turnOffSubtitleButton.addTarget(self, action: #selector(self.turnOffSubtitleAction), for: .touchUpInside)

        self.constraints()
    }

    private func replayVideo() {
        self.playerView.replay()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.playerView.viewController = self
    }

    private func constraints() {
        // ScrollView
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        self.scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true

        // PlayerView
        self.playerView.translatesAutoresizingMaskIntoConstraints = false
        self.playerView.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        self.playerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0)
            .isActive = true
        self.playerView.leadingAnchor.constraint(
            equalTo: self.scrollView.contentLayoutGuide.leadingAnchor,
            constant: 16.0
        ).isActive = true
        self.playerView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.height * 0.3).isActive = true

        // Main VStack
        self.vStack.translatesAutoresizingMaskIntoConstraints = false
        self.vStack.topAnchor.constraint(equalTo: self.playerView.bottomAnchor, constant: 20).isActive = true
        self.vStack.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor, constant: 16.0)
            .isActive = true
        self.vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
        self.vStack.heightAnchor.constraint(equalToConstant: 220).isActive = true
        self.vStack.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor, constant: -16)
            .isActive = true
    }

    @objc
    func pauseAction(sender _: UIButton!) {
        self.playerView.pause()
    }

    @objc
    func playAction(sender _: UIButton!) {
        self.playerView.play()
    }

    @objc
    func replayAction(sender _: UIButton!) {
        self.playerView.replay()
    }

    @objc
    func fullscreenAction(sender _: UIButton!) {
        self.playerView.goToFullScreen()
    }

    @objc
    func muteAction(sender _: UIButton!) {
        self.playerView.isMuted = true
    }

    @objc
    func unmuteAction(sender _: UIButton!) {
        self.playerView.isMuted = false
    }

    @objc
    func forwardAction(sender _: UIButton!) {
        self.playerView.seek(offset: CMTime(seconds: 15, preferredTimescale: 1_000))
    }

    @objc
    func backwardAction(sender _: UIButton!) {
        self.playerView.seek(offset: CMTime(seconds: -15, preferredTimescale: 1_000))
    }

    @objc
    func hideControlsAction(sender _: UIButton!) {
        self.playerView.hideControls()
    }

    @objc
    func frSubtitleAction(sender _: UIButton!) {
        self.playerView.currentSubtitle = Locale(identifier: "fr")
    }

    @objc
    func turnOffSubtitleAction(sender _: UIButton!) {
        self.playerView.hideSubtitle()
    }

    @objc
    func handleDoubleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let validSender = sender else { return }
        let viewCenterPosition = view.frame.width / 2
        let touchPoint = validSender.location(in: view)
        if touchPoint.x < viewCenterPosition {
            self.playerView.seek(offset: CMTime(seconds: -15, preferredTimescale: 1_000))
        } else {
            self.playerView.seek(offset: CMTime(seconds: 15, preferredTimescale: 1_000))
        }
    }

    @objc
    private func didSwipe(_: UISwipeGestureRecognizer) {
        self.playerView.goToFullScreen()
    }
}
