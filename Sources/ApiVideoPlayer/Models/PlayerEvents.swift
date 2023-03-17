import AVFoundation
import Foundation
/// Callbacks to get all player events
public class PlayerEvents {
    /// Events called when the player is preparing for a video
    public var didPrepare: (() -> Void)?
    /// Events called when the player is ready to play video
    public var didReady: (() -> Void)?
    /// Events called when the video is paused
    public var didPause: (() -> Void)?
    /// Events called when the video is playing
    public var didPlay: (() -> Void)?
    /// Events called when the video is replayed
    public var didReplay: (() -> Void)?
    /// Events called when the player is muted
    public var didMute: (() -> Void)?
    /// Events called when the player is unmuted
    public var didUnMute: (() -> Void)?
    /// Events called when the video is replayed in a loop
    public var didLoop: (() -> Void)?
    /// Events called when the player volume is changed
    public var didSetVolume: ((_ volume: Float) -> Void)?
    /// Events called when the player is seeking in the video
    public var didSeek: ((_ from: CMTime, _ to: CMTime) -> Void)?
    /// Events called when the video ended
    public var didEnd: (() -> Void)?
    /// Events called when there is an error with the player or video
    public var didError: ((_ error: Error) -> Void)?
    /// Events called when the size of the video changed
    public var didVideoSizeChanged: ((_ size: CGSize) -> Void)?

    public init(
        didPrepare: (() -> Void)? = nil,
        didReady: (() -> Void)? = nil,
        didPause: (() -> Void)? = nil,
        didPlay: (() -> Void)? = nil,
        didReplay: (() -> Void)? = nil,
        didMute: (() -> Void)? = nil,
        didUnMute: (() -> Void)? = nil,
        didLoop: (() -> Void)? = nil,
        didSetVolume: ((Float) -> Void)? = nil,
        didSeek: ((CMTime, CMTime) -> Void)? = nil,
        didEnd: (() -> Void)? = nil,
        didError: ((Error) -> Void)? = nil,
        didVideoSizeChanged: ((CGSize) -> Void)? = nil
    ) {
        self.didPrepare = didPrepare
        self.didReady = didReady
        self.didPause = didPause
        self.didPlay = didPlay
        self.didReplay = didReplay
        self.didMute = didMute
        self.didUnMute = didUnMute
        self.didLoop = didLoop
        self.didSetVolume = didSetVolume
        self.didSeek = didSeek
        self.didEnd = didEnd
        self.didError = didError
        self.didVideoSizeChanged = didVideoSizeChanged
    }
}
