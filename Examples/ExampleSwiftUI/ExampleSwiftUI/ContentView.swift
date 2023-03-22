import ApiVideoPlayer
import CoreMedia
import SwiftUI
struct ContentView: View {
    @State var isPlaying: Bool = false
    @State var videoOptions: VideoOptions? = VideoOptions(videoId: "vi4LEPFaRT5h4MlXE3FYyih8", videoType: VideoType.vod)

    var body: some View {
        VStack {
            ApiVideoPlayer(videoOptions: $videoOptions, isPlaying: $isPlaying)
                .onPlay {
                    print("onPlay")
                }
                .frame(height: 250)
                .padding(.bottom)
            HStack {
                Button(action: { isPlaying = true }, label: {
                    Text("Play")
                })
                Button(action: {
                    isPlaying = false
                }, label: {
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
