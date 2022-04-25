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
        player = PlayerSwiftUIView(videoId: "li5wq1x0g0v3AQws2Y5OyqJq", videoType: .live)
        player.getPaused({ (paused) in
            print()
        })
    }
    var body: some View {
        player
            .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.5, alignment: .center)
            .cornerRadius(40)
            
            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
