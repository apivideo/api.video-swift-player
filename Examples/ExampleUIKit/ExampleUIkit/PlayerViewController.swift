import UIKit
import ApiVideoPlayer
import AVKit

class PlayerViewController: UIViewController {
    
    private var didFinish: Bool = false {
        didSet{
            replayVideo()
        }
    }
    
    let customPlayer: ApiVideoPlayerView? = {
        let events = PlayerEvents(
            didPause: {() in
                print("paused")
            },
            didPlay: {() in
                print("play")
            },
            didRePlay: {() in
                print("video replayed")
            },
            didLoop: {() in
                print("video replayed from loop")
            },
            didSetVolume: {(volume) in
                print("volume set to : \(volume)")
            },
            didSeekTime: {(from, to)in
                print("seek from : \(from), to: \(to)")
            }
            
        )
        
        var player: ApiVideoPlayerView? = nil
        do {
//            vi17y1ATpEDRhq0vKoTX5OOT  -> no mp4
//            vi392sMkKB3aWs2vQetI0YLk
            player = try ApiVideoPlayerView(frame: .zero, videoId: "vi17y1ATpEDRhq0vKoTX5OOT", events: events)
        } catch {
            print("error during init, please check videoId")
        }
        
        return player
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
        scrollView.addSubview(customPlayer!)
       
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        customPlayer!.addGestureRecognizer(doubleTap)

        let swipeGestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        swipeGestureRecognizerRight.direction = .right
        customPlayer!.addGestureRecognizer(swipeGestureRecognizerRight)
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
    
    private func replayVideo(){
        customPlayer!.replay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        customPlayer!.setViewController(vc: self)
    }
    
    private func constraints(){
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true

        // PlayerView
        customPlayer!.translatesAutoresizingMaskIntoConstraints = false
        customPlayer!.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        customPlayer!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0).isActive = true
        customPlayer!.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16.0).isActive = true
        customPlayer!.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.height * 0.3).isActive = true
        
        
        // Main VStack
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.topAnchor.constraint(equalTo: customPlayer!.bottomAnchor, constant: 20).isActive = true
        vStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16.0 ).isActive = true
        vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
        vStack.heightAnchor.constraint(equalToConstant: 220).isActive = true
        vStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16).isActive = true
    }
    
    @objc func pauseAction(sender: UIButton!) {
        customPlayer!.pause()
    }
    @objc func playAction(sender: UIButton!) {
        customPlayer!.play()
    }
    @objc func replayAction(sender: UIButton!) {
        customPlayer!.replay()
    }
    @objc func fullscreenAction(sender: UIButton!) {
        customPlayer!.goFullScreen()
    }
    @objc func muteAction(sender: UIButton!) {
        customPlayer!.isMuted = true
    }
    @objc func unmuteAction(sender: UIButton!) {
        customPlayer!.isMuted = false
    }
    @objc func forwardAction(sender: UIButton!) {
        customPlayer!.seek(time: 15)
    }
    @objc func backwardAction(sender: UIButton!) {
        customPlayer!.seek(time: -15)
    }
    @objc func hideControlsAction(sender: UIButton!) {
        customPlayer!.hideControls()
    }
    @objc func frSubtitleAction(sender: UIButton!) {
        customPlayer!.showSubtitle(language: "fr")
    }
    @objc func turnOffSubtitleAction(sender: UIButton!) {
        customPlayer!.hideSubtitle()
    }
    
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer? = nil) {
        let viewCenterPosition = self.view.frame.width / 2
        let touchPoint = sender!.location(in: self.view)
        if(touchPoint.x < viewCenterPosition) {
            customPlayer!.seek(time: -15)
        }else{
            customPlayer!.seek(time: 15)
        }
    }
    
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        customPlayer!.goFullScreen()
    }
}
