import Foundation
import AVFoundation
import AVKit
import ApiVideoPlayerAnalytics

@available(iOS 14.0, *)
public class PlayerController{
    private(set) var avPlayer: AVPlayer!
    private var analytics: PlayerAnalytics?
    private var option : Options?
    private let videoType: VideoType = .vod
    private let videoId: String!
    public var events: PlayerEvents? = nil
    private var basicPlayerItem: AVPlayerItem!
    private var vodControlsView: VodControls?
    private var isHiddenControls = false
    private var timeObserver: Any?


    
    public var isReady: (() -> ())? = nil

    public var playerManifest: PlayerManifest!{
        didSet{
            self.isReady!()
        }
    }
    
    public var viewController: UIViewController?
    
    
    init(videoId: String, events: PlayerEvents? = nil) throws {
        self.events = events
        self.videoId = videoId
        
        getPlayerJSON(videoType: .vod){ (playerManifest, error) in
        }
        
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
    
    
    public func getPlayerJSON(videoType: VideoType, completion: @escaping (PlayerManifest?, Error?) -> Void){
        let request = RequestsBuilder().getPlayerData(path: getVideoUrl(videoType: videoType))
        let session = RequestsBuilder().buildUrlSession()
        TasksExecutor.execute(session: session, request: request) { (data,response, error) in
            if data != nil {
                do{
                    self.playerManifest = try JSONDecoder().decode(PlayerManifest.self, from: data!)
                }catch let decodeError{
                    completion(nil, decodeError)
                    return
                }
                    self.setUpAnalytics()
                    completion(self.playerManifest, nil)
            } else {
                    completion(nil, error)
            }
        }
        
    }
    
    private func setUpPlayer(_ view: UIView, _ playerLayer: AVPlayerLayer){
        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        if let url = URL(string: (self.playerManifest.video.src)){
            basicPlayerItem = AVPlayerItem(url: url)
        }else{
            if let urlMp4 = self.playerManifest.video.mp4 {
                basicPlayerItem = AVPlayerItem(url: URL(string: urlMp4)!)
            }else{
                return
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.donePlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: basicPlayerItem)
        let item = basicPlayerItem
        avPlayer = AVPlayer(playerItem: item)
        
        playerLayer.player = avPlayer
        view.layer.addSublayer(playerLayer)
        if(!isHiddenControls){
            self.vodControlsView = VodControls(frame: .zero, parentView: view, playerController: self)
            timeObserver = avPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { elapsedTime in
                self.vodControlsView!.updatePlayerState()
            })
        }
    }
    
    private func setUpAnalytics(){
        do {
              option = try Options(
                mediaUrl: self.playerManifest.video.src, metadata: [],
                onSessionIdReceived: { (id) in
                  print("session ID : \(id)")
                })
            } catch {
              print("error with the url")
            }

        analytics = PlayerAnalytics(options: option!)
    }
    
    public func setAvPlayerManifest(_ view: UIView,_ playerLayer: AVPlayerLayer){
        self.setUpPlayer(view, playerLayer)
    }
    
    
    
    
    public func isVideoPlaying()-> Bool{
        return avPlayer.isVideoPlaying()
    }
    
    public func play(){
        avPlayer.play()
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
    
    public var isMuted: Bool {
        get {
            return self.isMuted
        }
        set(newValue) {
            avPlayer.isMuted = newValue
            if newValue{
                if(self.events?.didMute != nil){
                    self.events?.didMute!()
                }
            }else{
                if(self.events?.didUnMute != nil){
                    self.events?.didUnMute!()
                }
            }
        }
    }
    
    
    public var volume: Float{
        get{ return avPlayer.volume}
        set(newVolume){
            avPlayer.volume = newVolume
            if(self.events?.didSetVolume != nil){
                self.events?.didSetVolume!(volume)
            }
        }
    }
    
    public var duration: CMTime{
        get{
            return avPlayer.currentItem!.asset.duration
        }
    }
    
    public var currentTime: CMTime{
        return avPlayer.currentTime()
    }
    
    public func goFullScreen(){
        let playerViewController = AVPlayerViewController()
        playerViewController.player = avPlayer
        viewController?.present(playerViewController, animated: true) {
            self.avPlayer.play()
        }
    }
    
    public func turnOffSubtitle(){
        if let group = avPlayer.currentItem!.asset.mediaSelectionGroup(forMediaCharacteristic: .legible){
            avPlayer.currentItem!.select(nil, in: group)
        }
    }
    
    public func showSubtitle(language: String){
        if let group = avPlayer.currentItem!.asset.mediaSelectionGroup(forMediaCharacteristic: .legible){
            let locale = Locale(identifier: language)
            let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: locale)
            if let option = options.first {
                avPlayer.currentItem!.select(option, in: group)
            }
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
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: basicPlayerItem)
    }
}
