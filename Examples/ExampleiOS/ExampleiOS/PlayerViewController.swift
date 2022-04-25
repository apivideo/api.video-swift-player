//
//  PlayerViewController.swift
//  ExampleiOS
//
//  Created by Romain Petit on 21/04/2022.
//

import UIKit
import ApiVideoPlayer
import AVKit

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var constraintLabel: UILabel!
    @IBOutlet weak var player: PlayerView!
    
    //private var events = PlayerEvents()
    
    private var didFinish: Bool = false {
        didSet{
            print("totto")
            replayVideo()
        }
    }
    
    let constraintPlayer: PlayerView = {
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
        
        let player = PlayerView(frame: .zero, videoId: "vi59FqvVyn2KjOC2vF21g2au", videoType: .vod, events: events)
        return player
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(constraintPlayer)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapMain(_:)))
        constraintPlayer.addGestureRecognizer(tap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        constraintPlayer.addGestureRecognizer(doubleTap)
        //constraintPlayer.isUserInteractionEnabled = true
        
        tap.require(toFail: doubleTap)
        
        let swipeGestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        swipeGestureRecognizerRight.direction = .right
        constraintPlayer.addGestureRecognizer(swipeGestureRecognizerRight)
        constraints()
        
        // Do any additional setup after loading the view.
    }
    
    private func replayVideo(){
        constraintPlayer.replay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        constraintPlayer.hideControls()
    }
    
    private func constraints(){
        constraintPlayer.translatesAutoresizingMaskIntoConstraints = false
        constraintPlayer.topAnchor.constraint(equalTo: constraintLabel.bottomAnchor, constant: 20).isActive = true
        constraintPlayer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        constraintPlayer.widthAnchor.constraint(equalToConstant: (view.frame.width - 40 )).isActive = true
        constraintPlayer.heightAnchor.constraint(equalToConstant: 400).isActive = true
    }
    
    @objc func handleTapMain(_ sender: UITapGestureRecognizer? = nil) {
        print("view tapped should start")
        if(constraintPlayer.isVideoPlaying()){
            self.constraintPlayer.pause()
        }else{
            self.constraintPlayer.play()
        }
    }
    
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer? = nil) {
        let viewCenterPosition = self.view.frame.width / 2
        let touchPoint = sender!.location(in: self.view)
        if(touchPoint.x < viewCenterPosition) {
            constraintPlayer.seek(time: -15)
        }else{
            constraintPlayer.seek(time: 15)
        }
    }
    
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        var vol = AVAudioSession.sharedInstance().outputVolume
        vol = vol + 0.1
        constraintPlayer.setVolume(volume: vol)
        print("volume: \(vol)")
    }
}
