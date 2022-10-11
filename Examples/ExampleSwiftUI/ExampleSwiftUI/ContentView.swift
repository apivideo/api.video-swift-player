import SwiftUI
import ApiVideoPlayer
struct ContentView: View {
    var player = ApiVideoPlayerSwiftUIView(videoId: "vi2G6Qr8ZVE67dWLNymk7qbc", videoType: .vod)
    var body: some View {
        VStack {
            player
                .frame(height: 200)
            Spacer()
            HStack{
                VStack {
                    Button(action: {
                        print("play")
                        player.play()
                    }){
                        Text("Play")
                }
                }
            }
        }
        Spacer()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
