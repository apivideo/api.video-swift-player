//
//  ContentView.swift
//  ExampleSwiftUI
//
//  Created by Romain Petit on 16/03/2022.
//

import SwiftUI
import ApiVideoPlayer

struct ContentView: View {
    private var player: PlayerSwiftUIView!
    init(){
        let events = PlayerEvents(
            didPause: {() in
                print("paused")
            },
            didPlay: {() in
                print("play")
            },
            didRePlay: {() in
                print("video replayed")
            },
            didMute: {() in
                print("video muted")
            },
            didUnMute: {() in
                print("video unMuted")
            },
            didLoop: {() in
                print("video replayed from loop")
            },
            didSetVolume: {(volume) in
                print("volume set to : \(volume)")
            },
            didSeekTime: {(from, to)in
                print("seek from : \(from), to: \(to)")
            },
            didFinish: {() in
                print("video finished")
            }
            
        )
        player = PlayerSwiftUIView(videoId: "vi5n7EGMKVS2x3nDbA29xu18", videoType: .vod, events: events)

    }
    var body: some View {
        VStack {
            player
                .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.5, alignment: .center)
            .cornerRadius(40)
            Spacer()
            VStack {
                Spacer()
                HStack {
                    Button("Pause") {
                        player.pause()
                    }
                    .padding()
                    Button("Play") {
                        player.play()
                    }
                    .padding()
                    Button("Replay") {
                        player.replay()
                    }
                    .padding()
                    Button("FullScreen") {
                        player.goFullScreen()
                    }
                    .padding()
                }
                Spacer()
                HStack {
                    Button("Mute") {
                        player.mute()
                    }
                    .padding()
                    Button("Unmute") {
                        player.unMute()
                    }
                    .padding()
                    Button("Seek +15s") {
                        player.seek(time: 15)
                    }
                    .padding()
                    Button("Seek -15s") {
                        player.seek(time: -15)
                    }
                    .padding()
                }
                Spacer()
                HStack {
                    Button("HideControls") {
                        player.hideControls()
                    }
                    .padding()
                }
                Spacer()
            }
            
        }
        
        
        
        
            
            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
