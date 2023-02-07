import ApiVideoPlayer
import SwiftUI
struct ContentView: View {
    private var player: ApiVideoPlayer
    init() {
        self.player = ApiVideoPlayer(videoOptions: VideoOptions(videoId: "YOUR-VIDEO-ID"))
    }

    var body: some View {
        VStack {
            player
                .frame(height: 250)
                .padding(.bottom)
            HStack {
                Button(action: { player.play() }, label: {
                    Text("Play")
                })
                Button(action: { player.pause() }, label: {
                    Text("Pause")
                })
            }
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
