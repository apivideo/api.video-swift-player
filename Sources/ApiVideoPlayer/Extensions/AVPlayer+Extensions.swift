import AVFoundation
import Foundation

extension AVPlayer {
    var isPlaying: Bool {
        rate != 0 && error == nil
    }

    var videoSize: CGSize {
        guard let size = self.currentItem?.presentationSize else {
            return .zero
        }
        return size
    }
}
