import Foundation

public struct VideoOptions {
    public var videoId: String
    public var videoType: VideoType

    /* only .vod is supported */
    public init(videoId: String, videoType: VideoType = VideoType.vod) {
        self.videoId = videoId
        self.videoType = videoType
    }
}

public enum VideoType: String {
    case vod
    case live
}
