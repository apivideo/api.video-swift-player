import CoreMedia
import Foundation

public class ApiVideoPlayerControllerMulticastDelegate {
    private let multicast = MulticastDelegate<PlayerDelegate>()

    init(_ delegates: [PlayerDelegate] = []) {
        addDelegates(delegates)
    }

    func addDelegate(_ delegate: PlayerDelegate) {
        multicast.add(delegate)
    }

    func addDelegates(_ delegates: [PlayerDelegate]) {
        delegates.forEach {
            addDelegate($0)
        }
    }

    func removeDelegate(_ delegate: PlayerDelegate) {
        multicast.remove(delegate)
    }

    func removeDelegates(_ delegates: [PlayerDelegate]) {
        delegates.forEach {
            removeDelegate($0)
        }
    }
}

// MARK: PlayerDelegate

extension ApiVideoPlayerControllerMulticastDelegate: PlayerDelegate {

    public func didPrepare() {
        multicast.invoke {
            $0.didPrepare()
        }
    }

    public func didPlay() {
        multicast.invoke {
            $0.didPlay()
        }
    }

    public func didReady() {
        multicast.invoke {
            $0.didReady()
        }
    }

    public func didPause() {
        multicast.invoke {
            $0.didPause()
        }
    }

    public func didReplay() {
        multicast.invoke {
            $0.didReplay()
        }
    }

    public func didMute() {
        multicast.invoke {
            $0.didMute()
        }
    }

    public func didUnMute() {
        multicast.invoke {
            $0.didUnMute()
        }
    }

    public func didLoop() {
        multicast.invoke {
            $0.didLoop()
        }
    }

    public func didSetVolume(_ volume: Float) {
        multicast.invoke {
            $0.didSetVolume(volume)
        }
    }

    public func didSeek(_ from: CMTime, _ to: CMTime) {
        multicast.invoke {
            $0.didSeek(from, to)
        }
    }

    public func didEnd() {
        multicast.invoke {
            $0.didEnd()
        }
    }

    public func didError(_ error: Error) {
        multicast.invoke {
            $0.didError(error)
        }
    }

    public func didVideoSizeChanged(_ size: CGSize) {
        multicast.invoke {
            $0.didVideoSizeChanged(size)
        }
    }
}
