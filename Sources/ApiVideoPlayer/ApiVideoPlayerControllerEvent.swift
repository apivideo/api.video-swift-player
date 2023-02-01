import Foundation
public class ApiVideoPlayerControllerEvent {
    public var videoTypeDidChanged: (() -> Void)?

    public init(videoTypeDidChanged: (() -> Void)? = nil) {
        self.videoTypeDidChanged = videoTypeDidChanged
    }
}
