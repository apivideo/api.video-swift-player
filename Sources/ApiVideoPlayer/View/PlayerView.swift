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
    var timeObserver: Any?
    let videoPlayerView = UIView()
    
    private let playerLayer = AVPlayerLayer()
    private var avPlayer: AVPlayer!
    private var isPlaying = false
    private var isLoop =  false
    
    private var vodControlsView: VodControls?
    private var liveControlsView: LiveControls?
    private var isHiddenControls = false
    private var isFullScreenAvailable = false
    
    public var events: PlayerEvents? = nil
    public var viewController: UIViewController? = nil {
        didSet{
            isFullScreenAvailable = !isFullScreenAvailable
            displayFullScreen()
            displayFullScreenAction()
        }
    }
    
    public init(frame: CGRect, videoId: String, videoType: VideoType, events: PlayerEvents? = nil) {
        self.videoId = videoId
        self.videoType = videoType
        self.events = events
        super.init(frame: frame)
        getPlayerJSON(videoType: videoType){ (player, error) in
            if player != nil{
                print("Current thread \(Thread.current)")
                self.setupView()
            }
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        self.videoId = "vi1fP8xxejHTkWH2I9ISpBTx"
        self.videoType = .vod
        self.events = PlayerEvents()
        super.init(coder: aDecoder)
        getPlayerJSON(videoType: videoType){ (player, error) in
            if player != nil{
                print("Current thread \(Thread.current)")
                self.setupView()
            }
        }
        
        //fatalError("init(coder:) has not been implemented")
    }
    
    public func setViewController(vc: UIViewController){
        self.viewController = vc
    }
        
    private func displayFullScreenAction(){
        //let playerLayer = AVPlayerLayer(player: avPlayer)
        if isFullScreenAvailable{
            self.layer.name = "customPlayer"
            self.viewController?.view.layer.addSublayer(self.layer)
            self.frame = (self.viewController?.view.layer.bounds)!
            
            if let sublayers = self.viewController?.view.layer.sublayers {
                print("---------")
                for layer in sublayers {
                    print(layer)
                    print(layer.name)
                }
                print("---------")
            }
        }else{
            //self.videoPlayerView.layer.sublayers?.removeAll()
            if let sublayers = self.viewController?.view.layer.sublayers {
                print("layer main view")
                for layer in sublayers {
                    print(layer)
                    print(layer.name)
                    if layer.name == "customPlayer" {
                        print("====== rm ======")
                        //layer.removeFromSuperlayer()
                    }
                }
            }
            //self.videoPlayerView.layer.addSublayer(self.layer)
            //self.layer.frame = self.videoPlayerView.layer.bounds
        }
    }
    
    private func displayFullScreen(){
        if isFullScreenAvailable {
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            playerLayer.goFullscreen()
        }else{
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            playerLayer.removeFullScreen()
        }
        
    }
    
    
    //https://cdn.api.video/vod/vi4HJALHgFlKMmosVsiI9nBd/player.json
    private func getVideoUrl(videoType: VideoType) -> String{
        var baseUrl = ""
        if videoType == .vod {
            baseUrl = "https://cdn.api.video/vod/"
        }else{
            baseUrl = "https://live.api.video/"
        }
        
        let url = baseUrl + "\(self.videoId!)/player.json"
        return url
    }
    
    private func getPlayerJSON(videoType: VideoType, completion: @escaping (Player?, Error?) -> Void){
        let request = RequestsBuilder().getPlayerData(path: getVideoUrl(videoType: videoType))
        let session = RequestsBuilder().buildUrlSession()
        TasksExecutor.execute(session: session, request: request) { (data, error) in
            if data != nil {
                self.player = try! JSONDecoder().decode(Player.self, from: data!)
                // TODO: handle the video mp4 if error on .m3u8
                // Fatal error: 'try!' expression unexpectedly raised an error: Swift.DecodingError.keyNotFound(CodingKeys(stringValue: "mp4", intValue: nil), Swift.DecodingError.Context(codingPath: [CodingKeys(stringValue: "video", intValue: nil)], debugDescription: "No value associated with key CodingKeys(stringValue: \"mp4\", intValue: nil) (\"mp4\").", underlyingError: nil))
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
        let item = AVPlayerItem(url: URL(string: player.video.src)!)
        NotificationCenter.default.addObserver(self, selector: #selector(self.donePlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        
        avPlayer = AVPlayer(playerItem: item)
        playerLayer.player = avPlayer
        self.layer.addSublayer(playerLayer)
        if(videoType == .vod){
            if(!isHiddenControls){
                self.vodControlsView = VodControls(frame: .zero, parentView: self, player: avPlayer)
                //self.vodControlsView?.hideControls()
                let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                timeObserver = avPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { elapsedTime in
                    self.vodControlsView!.updatePlayerState()
                })
            }
            
        }else{
            let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            
            if isHiddenControls {
                self.liveControlsView = LiveControls(frame: .zero, parentView: self, player: avPlayer)
                
                timeObserver = avPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { elapsedTime in
                    // liveControlsView.updatePlayerState()
                })
            }
            
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    
    public func isVideoPlaying() -> Bool{
        var isVideoPlaying = false
        if(avPlayer.timeControlStatus == .playing){
            isVideoPlaying = true
        }
        return isVideoPlaying
    }
    
    public func play(){
        avPlayer.play()
        isPlaying = true
        if(self.events?.didPlay != nil){
            self.events?.didPlay!()
        }
    }
    
    public func replay(){
        print("current time: \(getCurrentTime().seconds)")
        avPlayer.seek(to: CMTime.zero)
        avPlayer.play()
        if(self.events?.didRePlay != nil){
            self.events?.didRePlay!()
        }
    }
    public func pause(){
        avPlayer.pause()
        isPlaying = false
        if(self.events?.didPause != nil){
            self.events?.didPause!()
        }
    }
    public func mute(){
        avPlayer.isMuted = true
        if(self.events?.didMute != nil){
            self.events?.didMute!()
        }
    }
    public func unMute(){
        avPlayer.isMuted = false
        if(self.events?.didUnMute != nil){
            self.events?.didUnMute!()
        }
    }
    public func isMuted() -> Bool{
        return avPlayer.isMuted
    }
    public func hideControls(){
        isHiddenControls = true
        if(videoType == .vod){
            self.vodControlsView?.hideControls()
        }else{
            self.liveControlsView?.hideControls()
        }
    }
    public func showControls(){
        
    }
    public func showSubtitle(){
        if(self.events?.didShowSubtitle != nil){
            self.events?.didShowSubtitle!()
        }
    }
    public func hideSubtitle(){
        if(self.events?.didHideSubtitle != nil){
            self.events?.didHideSubtitle!()
        }
    }
    public func setLoop(loop: Bool){
        isLoop = true
    }
    public func seek(time: Double){
        guard let currentTime = avPlayer?.currentTime() else { return }
        var currentTimeInSeconds =  CMTimeGetSeconds(currentTime).advanced(by: time)
        let seekTime = CMTime(value: CMTimeValue(currentTimeInSeconds), timescale: 1)
        avPlayer?.seek(to: seekTime)
        if(self.events?.didSeekTime != nil){
            if currentTimeInSeconds < 0 {
                currentTimeInSeconds = 0.0
            }
            self.events?.didSeekTime!(currentTime.seconds, currentTimeInSeconds)
        }
    }
    public func setVolume(volume: Float){
        avPlayer.volume = volume
        if(self.events?.didSetVolume != nil){
            self.events?.didSetVolume!(volume)
        }
    }
    
    public func getDuration(completion: @escaping (CMTime) -> ()){
        completion(avPlayer.currentItem!.asset.duration)
    }
    public func getCurrentTime() -> CMTime{
        return avPlayer.currentTime()
    }
    
    @objc func donePlaying(sender: Notification) {
         //Dismiss AVPlayerViewController
        if isLoop {
            replay()
            if(self.events?.didLoop != nil){
                self.events?.didLoop!()
            }
        }
        if(self.events?.didFinish != nil){
            self.events?.didFinish!()
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

public struct PlayerEvents{
    public var didPause: (() -> ())? = nil
    public var didPlay: (() -> ())? = nil
    public var didRePlay: (() -> ())? = nil
    public var didMute: (() -> ())? = nil
    public var didUnMute: (() -> ())? = nil
    public var didShowSubtitle: (() -> ())? = nil
    public var didHideSubtitle: (() -> ())? = nil
    public var didLoop: (() -> ())? = nil
    public var didSetVolume: ((_ volume: Float) -> ())? = nil
    public var didSeekTime: ((_ from: Double, _ to: Double) -> ())? = nil
    public var didFinish: (() -> ())? = nil

    
    public init(didPause: (() -> ())? = nil, didPlay: (() -> ())? = nil, didRePlay: (() -> ())? = nil, didMute: (() -> ())? = nil, didUnMute:(() -> ())? = nil, didShowSubtitle: (() -> ())? = nil, didHideSubtitle: (() -> ())? = nil, didLoop: (() -> ())? = nil, didSetVolume: ((Float) -> ())? = nil, didSeekTime: ((Double,Double) -> ())? = nil, didFinish: (() -> ())? = nil) {
        self.didPause = didPause
        self.didPlay = didPlay
        self.didRePlay = didRePlay
        self.didMute = didMute
        self.didUnMute = didUnMute
        self.didLoop = didLoop
        self.didShowSubtitle = didShowSubtitle
        self.didHideSubtitle = didHideSubtitle
        self.didSetVolume = didSetVolume
        self.didSeekTime = didSeekTime
        self.didFinish = didFinish
    }
}

extension CGAffineTransform {

    static let ninetyDegreeRotation = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
    static let initialRotation = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
}

extension AVPlayerLayer {

    var fullScreenAnimationDuration: TimeInterval {
        return 0.15
    }

    func minimizeToFrame(_ frame: CGRect) {
        UIView.animate(withDuration: fullScreenAnimationDuration) {
            self.setAffineTransform(.identity)
            self.frame = frame
        }
    }

    func goFullscreen() {
        print("animation")
        UIView.animate(withDuration: fullScreenAnimationDuration) {
            //self.setAffineTransform(.ninetyDegreeRotation)
            self.frame = UIScreen.main.bounds
            let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }
    
    func removeFullScreen(){
        UIView.animate(withDuration: fullScreenAnimationDuration) {
            //self.setAffineTransform(.initialRotation)
            self.frame = UIScreen.main.bounds
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }
}
