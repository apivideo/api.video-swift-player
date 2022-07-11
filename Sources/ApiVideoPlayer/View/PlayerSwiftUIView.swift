import SwiftUI
import AVKit

@available(iOS 14.0, *)
@available(tvOS 13.0, *)
/// Player for SwuiftUI
public struct PlayerSwiftUIView: UIViewRepresentable {
    @State private var fullScreen = false
    
    let videoId: String!
    let events: PlayerEvents!
    var playerView: ApiPlayerView?
    
    /// Init method for the player
    /// - Parameters:
    ///   - videoId: Need videoid to display the video
    ///   - videoType: VideoType object to display vod or live controls
    ///   - events: Callback to get all the player events
    ///   - privateToken: Use only if your video is private, is nil by default
    public init(videoId : String, videoType: VideoType, events: PlayerEvents){
        self.videoId = videoId
        self.events = events
        
        do{
            playerView = try ApiPlayerView(frame: .zero, videoId: videoId, events: events)
        }catch{
            playerView = nil
        }
    }
    public func makeUIView(context: Context) -> UIView {
        if playerView != nil {
            return playerView!
        }else{
            return UIView(frame: .zero)
        }
    }
    
    public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerSwiftUIView>) {
        print("view upated")
    }
    

    
    /// Pause the video
    public func pause(){
        playerView?.pause()
    }
    /// Play the video
    public func play(){
        playerView?.play()
    }
    /// Replay the video
    public func replay(){
        playerView?.replay()
    }
    /// Get the current time of the video
    /// - Returns: Current time in CMTime
    public func getCurrentTime() -> CMTime{
       return playerView!.currentTime
    }
    /// Mute the playing video
    public func mute(){
        playerView?.isMuted = true
    }
    /// Unmute the playing video
    public func unMute(){
        playerView?.isMuted = false
    }
    /// Get audio state of the player
    /// - Returns: Boolean of the state of player's audio
    public func isMuted()->Bool{
        return playerView!.isMuted
    }
    /// Hide all the controls of the player
    /// By default the controls are on. They will be hide in case of inactivity, and display again on user interaction.
    public func hideControls(){
        playerView?.hideControls()
    }
    /// Video player is looping.
    /// (When the video play is finished, the player will start again the video)
    public func setLoop(){
        playerView?.setLoop()
    }
    /// Stop video looping
    public func stopLooping(){
        playerView?.stopLooping()
    }
    /// Go forward or backward in the video
    /// - Parameter time: time in seconds, (use minus to go backward)
    public func seek(time: Double){
        playerView?.seek(time: time)
    }
    /// The video player volume is connected to the device audio volume
    /// - Parameter volume: Float between 0 to 1 
    public func setVolume(volume: Float){
        playerView?.setVolume(volume: volume)
    }
//    /// Get the duration of the video
//    /// - Parameter completion: 
//    public func getDuration(completion: @escaping (CMTime) -> ()){
//        playerView?.getDuration(){ (duration) in
//            completion(duration)
//        }
//    }
    
    
    /// Display the player in fullscreen
    public func goFullScreen(){
        let controller = AVPlayerViewController()
        
        self.fullScreen.toggle()
        print(fullScreen.description)
    }
}

@available(iOS 14.0, *)
@available(tvOS 13.0.0, *)
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerSwiftUIView(videoId: "vi3wxypv6quTSFwXvg5XJ5az", videoType: .vod, events: PlayerEvents())
    }
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
