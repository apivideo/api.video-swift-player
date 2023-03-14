import Foundation

/// Description of the video to play.
public struct VideoOptions {
    public let videoId: String
    public let videoType: VideoType

    /// Init method for VideoOptions.
    /// - Parameters:
    ///   - videoId: the video Id of the video to play.
    ///   - videoType: the video type of the video to play.
    public init(videoId: String, videoType: VideoType = VideoType.vod) {
        self.videoId = videoId
        self.videoType = videoType
    }
}

public enum VideoType: String {
    case vod
    case live
}
