import Foundation
import AVFoundation
public class PlayerEvents {
    public var didPrepare: (() -> Void)?
    public var didPause: (() -> Void)?
    public var didPlay: (() -> Void)?
    public var didReplay: (() -> Void)?
    public var didMute: (() -> Void)?
    public var didUnMute: (() -> Void)?
    public var didLoop: (() -> Void)?
    public var didSetVolume: ((_ volume: Float) -> Void)?
    public var didSeek: ((_ from: CMTime, _ to: CMTime) -> Void)?
    public var didEnd: (() -> Void)?
    public var didError: ((_ error: Error) -> Void)?

    public init(didPrepare: (() -> Void)? = nil,
                didPause: (() -> Void)? = nil,
                didPlay: (() -> Void)? = nil,
                didReplay: (() -> Void)? = nil,
                didMute: (() -> Void)? = nil,
                didUnMute: (() -> Void)? = nil,
                didLoop: (() -> Void)? = nil,
                didSetVolume: ((Float) -> Void)? = nil,
                didSeek: ((CMTime, CMTime) -> Void)? = nil,
                didEnd: (() -> Void)? = nil,
                didError: ((Error) -> Void)? = nil)
    {
        self.didPrepare = didPrepare
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
    }
}
