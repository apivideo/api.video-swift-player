#if !os(macOS)
import UIKit
import AVKit

@available(tvOS 10.0, *)
@available(iOS 14.0, *)
public class ApiPlayerView: UIView {
    
    public let videoType: VideoType!
    public let videoId: String!
    public var events: PlayerEvents? = nil
    
    
    var player: Player!
    private var timeObserver: Any?
    private let videoPlayerView = UIView()
    private let playerLayer = AVPlayerLayer()
    public var avPlayer: AVPlayer!
    private var isPlaying = false
    private var isLoop =  false
    private var vodControlsView: VodControls?
    private var liveControlsView: LiveControls?
    private var playerController: PlayerController?
    private var isHiddenControls = false
    private var isFullScreenAvailable = false
    private var tokenVideo: String? = nil
    
    private var basicPlayerItem: AVPlayerItem!
    
    public var viewController: UIViewController? {
        didSet{
            vodControlsView?.viewController = viewController
            playerController?.viewController = viewController
        }
    }
    
   
    
    /// Init method for PlayerView
    /// - Parameters:
    ///   - frame: frame of theplayer view
    ///   - videoId: Need videoid to display the video
    ///   - videoType: VideoType object to display vod or live controls
    ///   - events: Callback to get all the player events
    ///   - privateToken: Use only if your video is private, is nil by default
    public init(frame: CGRect, videoId: String, videoType: VideoType, events: PlayerEvents? = nil, privateToken: String? = nil) throws {
        self.videoId = videoId
        self.videoType = videoType
        self.events = events
        super.init(frame: frame)
        var finalError: Error? = nil
        getPlayerJSON(videoType: videoType, privateToken: privateToken){ (player, error) in
            if player != nil{
                self.setupView()
            }else{
                print("error => \(error.debugDescription)")
                finalError = error
            }
        }
        
        if(finalError != nil){
            throw finalError!
        }
        
    }
        
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Set the UIViewController to be able to display the player in full screen
    /// - Parameter vc: pass your UIViewController
    public func setViewController(vc: UIViewController){
        self.viewController = vc
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
    
    private func getPlayerJSON(videoType: VideoType, privateToken: String? = nil, completion: @escaping (Player?, Error?) -> Void){
        let request = RequestsBuilder().getPlayerData(path: getVideoUrl(videoType: videoType, privateToken: privateToken))
        let session = RequestsBuilder().buildUrlSession()
        TasksExecutor.execute(session: session, request: request) { (data,response, error) in
            if data != nil {
                if let response = response as? HTTPURLResponse {
                    self.tokenVideo = response.value(forHTTPHeaderField: "x-token-session") ?? nil
                    print("Specific header: \(response.value(forHTTPHeaderField: "x-token-session") ?? " header not found")")
                }
                
                do{
                    self.player = try JSONDecoder().decode(Player.self, from: data!)
                }catch let decodeError{
                    completion(nil, decodeError)
                    return
                }
                DispatchQueue.main.async {
                    completion(self.player, nil)
                }
                
            } else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                
            }
        }
    }
    
    
    private func setupView(){
        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        if(self.traitCollection.userInterfaceStyle == .dark){
            self.backgroundColor = .lightGray
        }else{
            self.backgroundColor = .black
        }
        
        do{
            var url: String!
            if(tokenVideo != nil){
                url = player.video.src.replacingOccurrences(of: ":token", with: tokenVideo!)
                let headers: [String: String] = [
                    "X-Token-Session": tokenVideo!
                ]
                let asset = AVURLAsset(url: URL(string: url)!, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
                basicPlayerItem = AVPlayerItem(asset: asset)
                
            }else{
                url = player.video.src
                basicPlayerItem = AVPlayerItem(url: URL(string: url)!)
            }
        }catch{
            var url: String!
            if(tokenVideo != nil){
                url = player.video.mp4!.replacingOccurrences(of: ":token", with: tokenVideo!)
                let headers: [String: String] = [
                    "X-Token-Session": tokenVideo!
                ]
                let asset = AVURLAsset(url: URL(string: url)!, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
                basicPlayerItem = AVPlayerItem(asset: asset)
            }else{
                url = player.video.mp4!
                basicPlayerItem = AVPlayerItem(url: URL(string: url)!)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.donePlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: basicPlayerItem)
        let item = basicPlayerItem
        avPlayer = AVPlayer(playerItem: item)
        
        playerLayer.player = avPlayer
        self.layer.addSublayer(playerLayer)
        playerController = PlayerController(avPlayer: avPlayer, events, self.viewController, player: self.player)
        if(videoType == .vod){
            if(!isHiddenControls){
                self.vodControlsView = VodControls(frame: .zero, parentView: self, playerController: playerController!)
                timeObserver = avPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { elapsedTime in
                    self.vodControlsView!.updatePlayerState()
                })
            }
        }else{
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
    
    
    /// Get information if the video is playing
    /// - Returns: Boolean
    public func isVideoPlaying() -> Bool{
        return avPlayer.isVideoPlaying()
    }
    
    /// Play the video
    public func play(){
        playerController!.play()
    }
    
    /// Replay the video
    public func replay(){
        playerController!.replay()
    }
    
    /// Pause the video
    public func pause(){
        playerController!.pause()
    }
    /// Mute the playing video
    public func mute(){
        playerController!.mute()
    }
    /// Unmute the playing video
    public func unMute(){
        playerController!.unMute()
    }
    /// Get information if the video is muted or not
    /// - Returns: Boolean
    public func isMuted() -> Bool{
        return playerController!.isMuted()
    }
    /// Hide all the controls of the player
    /// By default the controls are on. They will be hide in case of inactivity, and display again on user interaction.
    public func hideControls(){
        isHiddenControls = true
        if(videoType == .vod){
            self.vodControlsView?.hideControls()
        }else{
            self.liveControlsView?.hideControls()
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
    
    /// Video player is looping.
    /// (When the video play is finished, the player will start again the video)
    public func setLoop(){
        isLoop = true
    }
    /// Stop video looping
    public func stopLooping(){
        isLoop = false
    }
    /// Go forward or backward in the video
    /// - Parameter time: time in seconds, (use minus to go backward)
    public func seek(time: Double){
        playerController!.seek(time: time)
    }
    /// The video player volume is connected to the device audio volume
    /// - Parameter volume: Float between 0 to 1
    public func setVolume(volume: Float){
        playerController!.setVolume(volume: volume)
    }
    
    // do setter getter
    public func getDuration()-> CMTime{
        return playerController!.getDuration()
    }
    public func getCurrentTime() -> CMTime{
        return playerController!.getCurrentTime()
    }
    
    public func goFullScreen(){
        isFullScreenAvailable = !isFullScreenAvailable
        playerController!.goFullScreen()
    }
    
    @objc func donePlaying(sender: Notification) {
        if isLoop {
            replay()
            if(self.events?.didLoop != nil){
                self.events?.didLoop!()
            }
        }
        if(self.events?.didEnd != nil){
            self.events?.didEnd!()
        }
    }
    
}

#else
import Cocoa
public class ApiPlayerView: NSView{
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
    // TODO: rename didEnd
    public var didEnd: (() -> ())? = nil
    
    
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
        self.didEnd = didFinish
    }
}
extension AVPlayer{
    @available(iOS 10.0, *)
    func isVideoPlaying()-> Bool{
        var isVideoPlaying = false
        if(self.timeControlStatus == .playing){
            isVideoPlaying = true
        }
        return isVideoPlaying
    }
}

