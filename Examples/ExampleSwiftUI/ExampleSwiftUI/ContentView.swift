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
        self.player = ApiVideoPlayer(videoOptions: VideoOptions(videoId: "YOUR-VIDEO-ID"), events: events)
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

    public func didPrepare() {
        print("app didPrepare")
    }

    public func didReady() {
        print("app didReady")
    }

    public func didPause() {
        print("app didPause")
    }

    public func didPlay() {
        print("app didPlay")
    }

    public func didReplay() {
        print("app didReplay")
    }

    public func didMute() {
        print("app didMute")
    }

    public func didUnMute() {
        print("app didUnMute")
    }

    public func didLoop() {
        print("app didLoop")
    }

    public func didSetVolume(_: Float) {
        print("app didSetVolume")
    }

    public func didSeek(_: CMTime, _: CMTime) {
        print("app didSeek")
    }

    public func didEnd() {
        print("app didEnd")
    }

    public func didError(_: Error) {
        print("app didError")
    }

    public func didVideoSizeChanged(_: CGSize) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
