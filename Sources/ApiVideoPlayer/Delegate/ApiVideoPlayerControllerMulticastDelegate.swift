import CoreMedia
import Foundation
public class ApiVideoPlayerControllerMulticastDelegate: PlayerEventsDelegate {
    private let multicast = MulticastDelegate<PlayerEventsDelegate>()

    init(_ delegates: [PlayerEventsDelegate]) {
        self.addDelegates(delegates)
    }

    func addDelegates(_ delegates: [PlayerEventsDelegate]) {
        delegates.forEach(self.multicast.add)
    }

    public func didPrepare() {
        self.multicast.invoke { $0.didPrepare() }
    }

    public func didPlay() {
        self.multicast.invoke { $0.didPlay() }
    }

    public func didReady() {
        self.multicast.invoke { $0.didReady() }
    }

    public func didPause() {
        self.multicast.invoke { $0.didPause() }
    }

    public func didReplay() {
        self.multicast.invoke { $0.didReplay() }
    }

    public func didMute() {
        self.multicast.invoke { $0.didMute() }
    }

    public func didUnMute() {
        self.multicast.invoke { $0.didUnMute() }
    }

    public func didLoop() {
        self.multicast.invoke { $0.didLoop() }
    }

    public func didSetVolume(_ volume: Float) {
        self.multicast.invoke { $0.didSetVolume(volume) }
    }

    public func didSeek(_ from: CMTime, _ to: CMTime) {
        self.multicast.invoke { $0.didSeek(from, to) }
    }

    public func didEnd() {
        self.multicast.invoke { $0.didEnd() }
    }

    public func didError(_ error: Error) {
        self.multicast.invoke { $0.didError(error) }
    }

    public func didVideoSizeChanged(_ size: CGSize) {
        self.multicast.invoke { $0.didVideoSizeChanged(size) }
    }
}
