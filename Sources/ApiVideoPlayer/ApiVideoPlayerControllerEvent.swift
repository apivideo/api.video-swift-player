import Foundation
public class ApiVideoPlayerControllerEvent {
    public var videoTypeDidChange: (() -> Void)?

    public init(videoTypeDidChange: (() -> Void)? = nil) {
        self.videoTypeDidChange = videoTypeDidChange
    }
}
