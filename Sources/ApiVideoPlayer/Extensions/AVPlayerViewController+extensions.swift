import AVKit
import Foundation

#if !os(macOS)
public extension AVPlayerViewController {
    /// Sets the player controller to use for this AVPlayerViewController.
    func setApiVideoPlayerController(_ controller: ApiVideoPlayerController) {
        player = controller.player
    }
}
#endif
