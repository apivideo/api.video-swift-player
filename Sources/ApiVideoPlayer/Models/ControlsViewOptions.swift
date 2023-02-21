import Foundation
public struct ControlsViewOptions {
    public var enableLiveButton: Bool
    public var enableForwardButton: Bool
    public var enableBackwardButton: Bool
    public var enableSubtitleButton: Bool

    public init(
        enableLiveButton: Bool = false,
        enableForwardButton: Bool = true,
        enableBackwardButton: Bool = true,
        enableSubtitleButton: Bool = false
    ) {
        self.enableLiveButton = enableLiveButton
        self.enableForwardButton = enableForwardButton
        self.enableBackwardButton = enableBackwardButton
        self.enableSubtitleButton = enableSubtitleButton
    }
}
