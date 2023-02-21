import Foundation

public struct VideoOptions {
    public let videoId: String
    public let videoType: VideoType

    public init(videoId: String, videoType: VideoType = VideoType.vod) {
        self.videoId = videoId
        self.videoType = videoType
    }
}

public enum VideoType: String {
    case vod
    case live
}
