#if !os(macOS)
import UIKit
import AVKit

@available(tvOS 10.0, *)
@available(iOS 14.0, *)
public class ApiVideoPlayerView: UIView {
    private let playerLayer = AVPlayerLayer()
    private let videoPlayerView = UIView()
    private var vodControlsView: VodControlsView?
    private var playerController: PlayerController!
    private var isFirstPlay = true
    public var viewController: UIViewController?{
        didSet{
            self.vodControlsView?.viewController = viewController
        }
    }
    
    /// Init method for PlayerView
    /// - Parameters:
    ///   - frame: frame of theplayer view
    ///   - videoId: Need videoid to display the video
    ///   - videoType: VideoType object to display vod or live controls
    ///   - events: Callback to get all the player events
    public init(frame: CGRect, videoId: String,hideControls: Bool = false, events: PlayerEvents? = nil) throws {
        super.init(frame: frame)
        do{
            playerController = try PlayerController(videoId: videoId, events: events, isReady: {() in
                DispatchQueue.main.async {
                    self.playerController?.setView(self,self.playerLayer)
                    if(!hideControls){
                        self.vodControlsView = VodControlsView(frame: .zero, parentView: self, playerController: self.playerController!)
                    }
                    self.setupView()
                }
            })
            
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    /// Get information if the video is playing
    /// - Returns: Boolean
    public func isPlaying() -> Bool{
        return playerController.isPlaying()
    }
    
    /// Play the video
    public func play(){
        playerController.play()
    }
    
    /// Replay the video
    public func replay(){
        playerController.replay()
    }
    
    /// Pause the video
    public func pause(){
        playerController.pause()
    }
    
    /// Getter and Setter to mute or unmute video player
    public var isMuted: Bool {
        get{return playerController.isMuted}
        set(newValue){ playerController.isMuted = newValue}
    }
    
    public var events: PlayerEvents?{
        get{return playerController.events}
        set(newValue){ playerController.events = newValue}
    }
    
    /// Hide all the controls of the player
    /// By default the controls are on. They will be hide in case of inactivity, and display again on user interaction.
    public func hideControls(){
        self.vodControlsView?.isHidden = true
    }
    
    /// Show all the controls of the player
    /// By default the controls are on. They will be hide in case of inactivity, and display again on user interaction.
    public func showControls(){
        self.vodControlsView?.isHidden = false
    }
    
    public func hideSubtitle(){
        playerController.hideSubtitle()
    }
    
    public func showSubtitle(language: String){
        playerController.showSubtitle(language: language)
    }
    
    /// Go forward or backward in the video
    /// - Parameter time: time in seconds, (use minus to go backward)
    public func seek(time: Double){
        playerController.seek(time: time)
    }
    /// Go forward or backward in the video to a specific time
    /// - Parameter to: go to a specific time (in second)
    public func seek(to: Double){
        playerController.seek(to: to)
    }
    
    /// The video player volume is connected to the device audio volume
    /// - Parameter volume: Float between 0 to 1
    public var volume: Float {
        get{
            playerController.volume
        }
        set(newValue){
            playerController.volume = newValue
        }
    }
    
    public var duration: CMTime{
        get{
            playerController.duration
        }
    }
    
    public var currentTime: CMTime{
        get{
            playerController.currentTime
        }
    }
    
    public func goFullScreen(){
        guard let vc = self.viewController else {
            return
        }
        playerController.goFullScreen(viewController: vc)
    }
    
    public var isLoop: Bool {
        get{
            playerController.isLoop
        }
        set(newValue){
            playerController.isLoop = newValue
        }
    }
    
    
}

#else
import Cocoa
public class ApiVideoPlayerView: NSView{
    override public init(frame: NSRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer?.backgroundColor = NSColor.red.cgColor
    }
}
#endif
