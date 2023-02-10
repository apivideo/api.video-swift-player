import ApiVideoPlayer
import CoreMedia
import SwiftUI
struct ContentView: View, PlayerEventsDelegate {
    private var player: ApiVideoPlayer
    init() {
        self.player = ApiVideoPlayer(videoOptions: VideoOptions(videoId: "YOUR-VIDEO-ID"))
    }

    var body: some View {
        VStack {
            player
                .onAppear {
                    self.player.addDelegate(delegate: self)
                }
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
