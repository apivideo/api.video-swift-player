import ApiVideoPlayer
import CoreMedia
import SwiftUI
struct ContentView: View {
    private var player: ApiVideoPlayer
    init() {
        let events = PlayerEvents(
            didPrepare: { () in
                print("swiftui app did prepare")
            },
            didPause: { () in
                print("swiftui app paused")
            },
            didPlay: { () in
                print("swiftui app play")
            },
            didReplay: { () in
                print("swiftui app video replayed")
            },
            didLoop: { () in
                print("swiftui app video replayed from loop")
            },
            didSeek: { from, to in
                print("swiftui app seek from : \(from), to: \(to)")
            },
            didError: { error in
                print("swiftui app error \(error)")
            }
        )
        self.player = ApiVideoPlayer(
            videoOptions: VideoOptions(videoId: "YOUR-VIDEO-ID", videoType: .vod),
            events: events
        )
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
