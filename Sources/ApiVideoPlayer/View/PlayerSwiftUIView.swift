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
    public init(videoId : String, videoType: VideoType){
        self.videoId = videoId
        self.videoType = videoType
    }
    public func makeUIView(context: Context) -> UIView {
        return PlayerView(frame: .zero, videoId: videoId, videoType: videoType)
    }
    
    public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerSwiftUIView>) {
        
    }
}

@available(iOS 13.0, *)
@available(tvOS 13.0.0, *)
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerSwiftUIView(videoId: "toto", videoType: .vod)
    }
}
