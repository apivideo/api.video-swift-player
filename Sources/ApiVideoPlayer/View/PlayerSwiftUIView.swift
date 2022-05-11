//
//  SwiftUIView.swift
//  
//
//  Created by Romain Petit on 16/03/2022.
//

import SwiftUI
import AVKit

@available(iOS 13.0, *)
@available(tvOS 13.0, *)
public struct PlayerSwiftUIView: UIViewRepresentable {
    let videoId: String!
    let videoType: VideoType!
    let events: PlayerEvents!
    var playerView: PlayerView?
    
    public init(videoId : String, videoType: VideoType, events: PlayerEvents){
        self.videoId = videoId
        self.videoType = videoType
        self.events = events
        
        do{
            playerView = try PlayerView(frame: .zero, videoId: videoId, videoType: videoType, events: events)
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
        
    }
    public func pause(){
        playerView?.pause()
    }
    public func play(){
        playerView?.play()
        
    }
    public func replay(){
        playerView?.replay()
    }
    public func getCurrentTime() -> CMTime{
       return playerView!.getCurrentTime()
    }
    public func mute(){
        playerView?.mute()
    }
    public func unMute(){
        playerView?.unMute()
    }
    public func isMuted()->Bool{
        return ((playerView?.isMuted()) != nil)
    }
    public func hideControls(){
        playerView?.hideControls()
    }
    public func setLoop(){
        playerView?.setLoop()
    }
    public func stopLooping(){
        playerView?.stopLooping()
    }
    public func seek(time: Double){
        playerView?.seek(time: time)
    }
    public func setVolume(volume: Float){
        playerView?.setVolume(volume: volume)
    }
    public func getDuration(completion: @escaping (CMTime) -> ()){
        playerView?.getDuration(){ (duration) in
            completion(duration)
        }
    }
    
    
    public func goFullScreen(){
        playerView?.goFullScreen()
    }
}

@available(iOS 13.0, *)
@available(tvOS 13.0.0, *)
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerSwiftUIView(videoId: "toto", videoType: .vod, events: PlayerEvents())
    }
}
