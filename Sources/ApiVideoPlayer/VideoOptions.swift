import Foundation

public struct VideoOptions {
    public var videoId: String
    public var videoType: VideoType

    public init(videoId: String, videoType: VideoType) {
        self.videoId = videoId
        self.videoType = videoType
    }
}

public enum VideoType: String {
    case vod
    case live
}
