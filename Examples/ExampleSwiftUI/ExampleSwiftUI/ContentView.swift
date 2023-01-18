import ApiVideoPlayer
import SwiftUI
struct ContentView: View {
    private var player: ApiVideoPlayer
    init() {
        let events = PlayerEvents(
            didPause: { () in
                print("paused")
            },
            didPlay: { () in
                print("play")
            },
            didReplay: { () in
                print("video replayed")
            },
            didLoop: { () in
                print("video replayed from loop")
            },
            didSeek: { from, to in
                print("seek from : \(from), to: \(to)")
            },
            didError: { error in
                print("error \(error)")
            }
        )
        self.player = ApiVideoPlayer(videoId: "vi2G6Qr8ZVE67dWLNymk7qbc", videoType: .vod, events: events)
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
