import AVFoundation
import Foundation

/// Callbacks to be notified of the player events.
public class PlayerEvents {
    /// Event called before the video URL will passed to the player.
    public var didPrepare: (() -> Void)?
    /// Event called when the player is ready to play video.
    public var didReady: (() -> Void)?
    /// Event called when the video has been paused.
    public var didPause: (() -> Void)?
    /// Event called when the video has been played.
    public var didPlay: (() -> Void)?
    /// Event called when the video has been replayed.
    public var didReplay: (() -> Void)?
    /// Event called when the player has been muted.
    public var didMute: (() -> Void)?
    /// Event called when the player has been unmuted.
    public var didUnmute: (() -> Void)?
    /// Event called when the video has been replayed in a loop.
    public var didLoop: (() -> Void)?
    /// Event called when the player volume has been changed.
    public var didSetVolume: ((_ volume: Float) -> Void)?
    /// Event called when the playback position has changed.
    public var didSeek: ((_ from: CMTime, _ to: CMTime) -> Void)?
    /// Events called when the video ended.
    public var didEnd: (() -> Void)?
    /// Events called when there is an error with the player or video.
    public var didError: ((_ error: Error) -> Void)?
    /// Events called when the size of the video changed.
    public var didVideoSizeChanged: ((_ size: CGSize) -> Void)?

    /// Initializes a new instance of `PlayerEvents`.
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
        self.didUnmute = didUnMute
        self.didLoop = didLoop
        self.didSetVolume = didSetVolume
        self.didSeek = didSeek
        self.didEnd = didEnd
        self.didError = didError
        self.didVideoSizeChanged = didVideoSizeChanged
    }
}
