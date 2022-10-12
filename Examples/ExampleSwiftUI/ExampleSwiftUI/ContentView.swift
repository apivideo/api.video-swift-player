import ApiVideoPlayer
import SwiftUI
struct ContentView: View {
//  var player = ApiVideoPlayerSwiftUIView(videoId: "vi2G6Qr8ZVE67dWLNymk7qbc", videoType: .vod)
  var player = SwiftUIPlayerView(videoId: "vi2G6Qr8ZVE67dWLNymk7qbc", videoType: .vod)
  var body: some View {
    VStack {
      player
        .frame(height: 250)
        .padding(.bottom)
      HStack {
        Button(action: {
          print("play")
          player.play()
        }) {
          Text("Play")
        }
        Button(action: {
          print("pause")
          player.pause()
        }) {
          Text("Pause")
        }
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
