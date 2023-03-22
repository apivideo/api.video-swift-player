import AVFoundation
import Foundation
/// An interface that delegates of an instance to handle the player events.
public protocol ApiVideoPlayerControllerPlayerDelegate: AnyObject {
    /// Event called before the video URL will passed to the player.
    func didPrepare()
    /// Event called when the player is ready to play video.
    func didReady()
    /// Event called when the video has been paused.
    func didPause()
    /// Event called when the video has been played.
    func didPlay()
    /// Event called when the video has been replayed.
    func didReplay()
    /// Event called when the player has been muted.
    func didMute()
    /// Event called when the player has been unmuted.
    func didUnMute()
    /// Event called when the video has been replayed in a loop.
    func didLoop()
    /// Event called when the player volume has been changed.
    func didSetVolume(_ volume: Float)
    /// Event called when the playback position has changed.
    func didSeek(_ from: CMTime, _ to: CMTime)
    /// Events called when the video ended.
    func didEnd()
    /// Events called when there is an error with the player or video.
    func didError(_ error: Error)
    /// Events called when the size of the video changed.
    func didVideoSizeChanged(_ size: CGSize)
}
