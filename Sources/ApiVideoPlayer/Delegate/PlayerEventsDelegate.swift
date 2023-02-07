import AVFoundation
import Foundation
public protocol PlayerEventsDelegate: AnyObject {
    /// Events called when the player is preparing for a video
    func didPrepare()
    /// Events called when the player is ready to play video
    func didReady()
    /// Events called when the video is paused
    func didPause()
    /// Events called when the video is playing
    func didPlay()
    /// Events called when the video is replayed
    func didReplay()
    /// Events called when the player is muted
    func didMute()
    /// Events called when the player is unmuted
    func didUnMute()
    /// Events called when the video is replayed in a loop
    func didLoop()
    /// Events called when the player volume is changed
    func didSetVolume(_ volume: Float)
    /// Events called when the player is seeking in the video
    func didSeek(_ from: CMTime, _ to: CMTime)
    /// Events called when the video ended
    func didEnd()
    /// Events called when there is an error with the player or video
    func didError(_ error: Error)
    /// Events called when the size of the video changed
    func didVideoSizeChanged(_ size: CGSize)
}
