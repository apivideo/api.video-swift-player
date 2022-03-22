//
//  PlayerView.swift
//  
//
//  Created by Romain Petit on 16/03/2022.
//

#if !os(macOS)
import UIKit
import AVKit

@available(tvOS 10.0, *)
@available(iOS 13.0, *)
public class PlayerView: UIView {
    var player: Player!
    let videoType: VideoType!
    let videoId: String!
    
    let playPauseButton: UIButton = {
        let btn = UIButton(type: .system)
        return btn
    }()
    let videoPlayerView = UIView()
    
    private let playerLayer = AVPlayerLayer()
    private var avPlayer: AVPlayer!
    private var isPlaying = false
    
    
    init(frame: CGRect, videoId: String, videoType: VideoType) {
        self.videoId = videoId
        self.videoType = videoType
        super.init(frame: frame)
        print("Current thread \(Thread.current)")
        getPlayerJSON(){ (player, error) in
            if player != nil{
                print("Current thread \(Thread.current)")
                self.setupView()
            }
        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //https://cdn.api.video/vod/vi4HJALHgFlKMmosVsiI9nBd/player.json
    private func getVideoUrl() -> String{
        let baseUrl = "https://cdn.api.video/"
        let url = baseUrl + self.videoType.rawValue + "/\(self.videoId!)/player.json"
        return url
    }
    
    private func getPlayerJSON(completion: @escaping (Player?, Error?) -> Void){
        let request = RequestsBuilder().getPlayerData(path: getVideoUrl())
        let session = RequestsBuilder().buildUrlSession()
        TasksExecutor.execute(session: session, request: request) { (data, error) in
            if data != nil {
                self.player = try! JSONDecoder().decode(Player.self, from: data!)
                print("player : \(String(describing: self.player))")
                print("Current thread \(Thread.current)")
                DispatchQueue.main.async {
                    completion(self.player, nil)
                }
                
//                let json = try? JSONSerialization.jsonObject(with: data!) as? [String: AnyObject]
//                print("json response : \(String(describing: json))")
            } else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                
            }
        }
    }
    
    
    private func setupView(){
        print("Current thread \(Thread.current)")
        if(self.traitCollection.userInterfaceStyle == .dark){
            self.backgroundColor = .lightGray
        }else{
            self.backgroundColor = .black
        }
        
        self.addSubview(playPauseButton)
        playPauseButton.addTarget(self, action: #selector(seekPlayAction), for: .touchUpInside)
        getIconPlayBtn()
        avPlayer = AVPlayer(url: URL(string: player.video.src)!)
        playerLayer.player = avPlayer
        self.layer.addSublayer(playerLayer)
        self.bringSubviewToFront(playPauseButton)
        constraints()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    private func constraints(){
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        playPauseButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        playPauseButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        playPauseButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    
    @objc func seekPlayAction() {
        print("seek play")
        if !isPlaying{
            avPlayer.play()
            isPlaying = true
        }else{
            avPlayer.pause()
            isPlaying = false
        }
        getIconPlayBtn()
    }
    
    
    private func getIconPlayBtn(){
        if !isPlaying{
            if #available(tvOS 13.0, *) {
                playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            playPauseButton.tintColor = .systemOrange
        }else{
            if #available(tvOS 13.0, *) {
                playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            playPauseButton.tintColor = .systemOrange
        }
    }
    
}

#else
import Cocoa

public class PlayerView: NSView{
    override public init(frame: NSRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer?.backgroundColor = NSColor.red.cgColor
    }
}
#endif
