import Foundation
public struct PlayerEvents{
    public var didPause: (() -> ())? = nil
    public var didPlay: (() -> ())? = nil
    public var didRePlay: (() -> ())? = nil
    public var didMute: (() -> ())? = nil
    public var didUnMute: (() -> ())? = nil
    public var didLoop: (() -> ())? = nil
    public var didSetVolume: ((_ volume: Float) -> ())? = nil
    public var didSeekTime: ((_ from: Double, _ to: Double) -> ())? = nil
    public var didEnd: (() -> ())? = nil
    public var didPlayerError: ((_ error: Error) -> ())? = nil
    
    
    public init(didPause: (() -> ())? = nil, didPlay: (() -> ())? = nil, didRePlay: (() -> ())? = nil, didMute: (() -> ())? = nil, didUnMute:(() -> ())? = nil, didLoop: (() -> ())? = nil, didSetVolume: ((Float) -> ())? = nil, didSeekTime: ((Double,Double) -> ())? = nil, didEnd: (() -> ())? = nil, didPlayerError: ((Error) -> ())? = nil) {
        self.didPause = didPause
        self.didPlay = didPlay
        self.didRePlay = didRePlay
        self.didMute = didMute
        self.didUnMute = didUnMute
        self.didLoop = didLoop
        self.didSetVolume = didSetVolume
        self.didSeekTime = didSeekTime
        self.didEnd = didEnd
        self.didPlayerError = didPlayerError
    }
}
