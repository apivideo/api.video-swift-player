import Foundation
import AVFoundation
import AVKit
import ApiVideoPlayerAnalytics

public class PlayerController{
    public var avPlayer: AVPlayer!{
        didSet{
            NotificationCenter.default.addObserver(self, selector: #selector(self.donePlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
        }
    }
    private var analytics: PlayerAnalytics?
    private var option : Options?
    public let videoType: VideoType = .vod
    public let videoId: String!
    public var events: PlayerEvents? = nil

    public var player: Player!
    
    public var viewController: UIViewController? {
        didSet{
            print("view controller set")
        }
    }
    public var isPlaying = false {
        didSet{
            
        }
    }
    
    init(videoId: String, events: PlayerEvents? = nil) throws {
        self.events = events
        self.videoId = videoId
    }
    
    
    
    
    
    private func getVideoUrl(videoType: VideoType, privateToken: String? = nil) -> String{
        var baseUrl = ""
        if videoType == .vod {
            baseUrl = "https://cdn.api.video/vod/"
        }else{
            baseUrl = "https://live.api.video/"
        }
        var url: String!
        if privateToken != nil{
            url = baseUrl + "\(self.videoId!)/token/\(privateToken!)/player.json"
        }else{
            url = baseUrl + "\(self.videoId!)/player.json"
        }
        
        return url
    }
    
    
    public func getPlayerJSON(videoType: VideoType, completion: @escaping (Player?, Error?) -> Void){
        let request = RequestsBuilder().getPlayerData(path: getVideoUrl(videoType: videoType))
        let session = RequestsBuilder().buildUrlSession()
        TasksExecutor.execute(session: session, request: request) { (data,response, error) in
            if data != nil {
                do{
                    self.player = try JSONDecoder().decode(Player.self, from: data!)
                }catch let decodeError{
                    completion(nil, decodeError)
                    return
                }
                DispatchQueue.main.async {
                    self.setUpAnalytics()
                    completion(self.player, nil)
                }
                
            } else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                
            }
        }
        
    }
    
    private func setUpAnalytics(){
        do {
              option = try Options(
                mediaUrl: self.player.video.src, metadata: [],
                onSessionIdReceived: { (id) in
                  print("session ID : \(id)")
                })
            } catch {
              print("error with the url")
            }

        analytics = PlayerAnalytics(options: option!)
    }
    
    
    
    
    @available(iOS 10.0, *)
    public func isVideoPlaying()-> Bool{
        return avPlayer.isVideoPlaying()
    }
    
    public func play(){
        avPlayer.play()
        isPlaying = true
        if(self.events?.didPlay != nil){
            self.events?.didPlay!()
        }
    }
    
    public func replay(){
        analytics?.seek(from: Float(CMTimeGetSeconds(avPlayer.currentTime())), to: Float(CMTimeGetSeconds(CMTime.zero))){ (result) in
            switch result {
            case .success(let data):
                print("player analytics seek : \(data)")
            case .failure(let error):
                print("player analytics seek : \(error)")
            }
        }
        avPlayer.seek(to: CMTime.zero)
        avPlayer.play()
        analytics?.resume(){(result) in
            switch result {
            case .success(let data):
                print("player analytics play : \(data)")
            case .failure(let error):
                print("player analytics play : \(error)")
            }
        }
        
        if(self.events?.didRePlay != nil){
            self.events?.didRePlay!()
        }
    }
    
    public func pause(){
        avPlayer.pause()
        isPlaying = false
        analytics?.pause(){(result) in
            switch result {
            case .success(let data):
                print("player analytics pause : \(data)")
            case .failure(let error):
                print("player analytics pause : \(error)")
            }
        }
        if(self.events?.didPause != nil){
            self.events?.didPause!()
        }
    }
    
    public func seek(time: Double){
        guard let currentTime = avPlayer?.currentTime() else { return }
        var currentTimeInSeconds =  CMTimeGetSeconds(currentTime).advanced(by: time)
        let seekTime = CMTime(value: CMTimeValue(currentTimeInSeconds), timescale: 1)
        avPlayer?.seek(to: seekTime)
        analytics?.seek(from: Float(CMTimeGetSeconds(currentTime)), to: Float(CMTimeGetSeconds(seekTime))){(result) in
            switch result {
            case .success(let data):
                print("player analytics seek : \(data)")
            case .failure(let error):
                print("player analytics seek : \(error)")
            }
        }
        if(self.events?.didSeekTime != nil){
            if currentTimeInSeconds < 0 {
                currentTimeInSeconds = 0.0
            }
            self.events?.didSeekTime!(currentTime.seconds, currentTimeInSeconds)
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
    
    public func setVolume(volume: Float){
        avPlayer.volume = volume
        if(self.events?.didSetVolume != nil){
            self.events?.didSetVolume!(volume)
        }
    }
    
    public func getDuration() -> CMTime{
        return avPlayer.currentItem!.asset.duration
    }
    
    public func getCurrentTime() -> CMTime{
        return avPlayer.currentTime()
    }
    
    @available(iOS 11.0, *)
    public func goFullScreen(){
        let playerViewController = AVPlayerViewController()
        playerViewController.player = avPlayer
        print("view controller \(self.viewController.debugDescription)")
        viewController?.present(playerViewController, animated: true) {
            self.avPlayer.play()
        }
    }
    
    @objc func donePlaying(sender: Notification) {
        analytics?.end(){(result)in
            switch result {
            case .success(let data):
                print("player analytics video ended successfully : \(data)")
            case .failure(let error):
                print("player analytics video ended with an error : \(error)")
            }
        }
        if(self.events?.didEnd != nil){
            self.events?.didEnd!()
        }
    }
}
