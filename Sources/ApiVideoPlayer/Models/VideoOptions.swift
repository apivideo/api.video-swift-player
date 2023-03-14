import Foundation

/// Description of the video to play.
public struct VideoOptions {
    public let videoId: String
    public let videoType: VideoType
    public let token: String?

    public let hlsManifestUrl: String
    public let sessionTokenUrl: String
    public let mp4Url: String
    public let thumbnailUrl: String

    /// Init method for VideoOptions.
    /// - Parameters:
    ///   - videoId: the video Id of the video to play.
    ///   - videoType: the video type of the video to play.
    ///   - token: the private token the video to play.
    public init(videoId: String, videoType: VideoType, token: String? = nil) {
        self.videoId = videoId
        self.videoType = videoType
        self.token = token

        let baseUrl = "\(videoType.rawValue)/\(videoId)"
        var vodUrl = baseUrl
        var liveUrl = "\(videoType.rawValue)"
        if let token = token {
            vodUrl.append("/token/\(token)")
            liveUrl.append("/private/\(token)")
        }
        liveUrl.append("/\(videoId)")

        if videoType == .vod {
            self.hlsManifestUrl = "\(vodUrl)/hls/manifest.m3u8"
            self.sessionTokenUrl = "\(vodUrl)/session"
        } else {
            self.hlsManifestUrl = "\(liveUrl).m3u8"
            self.sessionTokenUrl = self.hlsManifestUrl
        }

        self.mp4Url = "\(vodUrl)/mp4/source.mp4"
        self.thumbnailUrl = "\(vodUrl)/thumbnail.jpg"
    }
}

public enum VideoType: String {
    case vod = "https://vod.api.video/vod"
    case live = "https://live.api.video"
}
