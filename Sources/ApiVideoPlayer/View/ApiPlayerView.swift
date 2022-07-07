#if !os(macOS)
import UIKit
import AVKit

@available(tvOS 10.0, *)
@available(iOS 14.0, *)
public class ApiPlayerView: UIView {
    
    public let videoId: String!
    public var events: PlayerEvents? = nil
    private var basicPlayerItem: AVPlayerItem!
    private let playerLayer = AVPlayerLayer()
    private var timeObserver: Any?
    private let videoPlayerView = UIView()
    private var isLoop =  false
    private var vodControlsView: VodControls?
    private(set) var playerController: PlayerController?
    private var isHiddenControls = false
    private var isFirstPlay = true
    
    public var viewController: UIViewController? {
        didSet{
            playerController?.viewController = viewController
        }
    }
    
   
    
    /// Init method for PlayerView
    /// - Parameters:
    ///   - frame: frame of theplayer view
    ///   - videoId: Need videoid to display the video
    ///   - videoType: VideoType object to display vod or live controls
    ///   - events: Callback to get all the player events
    public init(frame: CGRect, videoId: String, events: PlayerEvents? = nil) throws {
        self.videoId = videoId
        self.events = events
        super.init(frame: frame)
        
        do{
            playerController = try PlayerController(videoId: videoId, events: events)
            
            playerController?.isReady = {() in
                print("is ready")
                DispatchQueue.main.async {
                    self.playerController?.setAvPlayerManifest(self,self.playerLayer)
                    self.playerController?.avPlayer.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
                    self.setupView()
                }
            }
        }catch{
            return
        }
                
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(){
        if(self.traitCollection.userInterfaceStyle == .dark){
            self.backgroundColor = .lightGray
        }else{
            self.backgroundColor = .black
        }
    }
    
    /// Set the UIViewController to be able to display the player in full screen
    /// - Parameter vc: pass your UIViewController
    public func setViewController(vc: UIViewController){
        self.viewController = vc
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    
    /// Get information if the video is playing
    /// - Returns: Boolean
    public func isVideoPlaying() -> Bool{
        return playerController?.avPlayer.isVideoPlaying() ?? false
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
    
    /// Getter and Setter to mute or unmute video player
    public var isMuted: Bool {
        get{return playerController!.isMuted}
        set(newValue){ playerController!.isMuted = newValue}
    }
    
    /// Hide all the controls of the player
    /// By default the controls are on. They will be hide in case of inactivity, and display again on user interaction.
    public func hideControls(){
        isHiddenControls = true
        self.vodControlsView?.hideControls()
    }
    
    public func turnOffSubtitle(){
        playerController?.turnOffSubtitle()
    }
    
    public func showSubtitle(language: String){
        playerController?.showSubtitle(language: language)
    }
    
    
    public var isLooping: Bool = false
    
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
        playerController!.volume = volume
    }
    
    // do setter getter
    var duration: CMTime{
        get{
            playerController!.duration
        }
    }
    
    var currentTime: CMTime{
        get{
            playerController!.currentTime
        }
    }
    
    public func goFullScreen(){
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
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            if let status = playerController?.avPlayer.timeControlStatus {
                switch status{
                case .paused:
                    //Paused mode
                    playerController?.analytics?.pause(){(result) in
                        switch result {
                        case .success(_): break
                        case .failure(let error):
                            print("analytics error on pause event: \(error)")
                        }
                    }
                    if(self.events?.didPause != nil){
                        self.events?.didPause!()
                    }
                case .waitingToPlayAtSpecifiedRate:
                    //Resumed
                    if(isFirstPlay){
                        isFirstPlay = false
                        playerController?.analytics?.play(){(result) in
                            switch result {
                            case .success(_): break
                            case .failure(let error):
                                print("analytics error on play event: \(error)")
                            }
                        }
                    }else{
                        playerController?.analytics?.resume(){(result) in
                            switch result {
                            case .success(_): break
                            case .failure(let error):
                                print("analytics error on resume event: \(error)")
                            }
                        }
                    }
                    if(self.events?.didPlay != nil){
                        self.events?.didPlay!()
                    }
                case .playing:
                    //Video Ended
                        playerController?.analytics?.end(){(result)in
                        switch result {
                        case .success(_):break
                        case .failure(let error):
                            print("analytics error on ended event: \(error)")
                        }
                    }
                    if(self.events?.didEnd != nil){
                        self.events?.didEnd!()
                    }
                @unknown default:
                    break
                }
            }
        }
    }
    
    deinit {
        playerController!.avPlayer.removeObserver(self, forKeyPath: "rate", context: nil)
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
        return (self.rate != 0 && self.error == nil)
    }
}
