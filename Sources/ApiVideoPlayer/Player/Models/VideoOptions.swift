import Foundation

/// Description of a video.
public struct VideoOptions {
    /// The video Id (from api.video) of the video.
    public let videoId: String
    /// The video type of the video(ie VOD or Live).
    public let videoType: VideoType
    /// The private token of the video. If video is public, this parameter is nil.
    public let token: String?

    let hlsManifestUrl: String
    let sessionTokenUrl: String
    let mp4Url: String
    let thumbnailUrl: String

    /// Initializes a video options from the video Id and the video type.
    /// - Parameters:
    ///   - videoId: The video Id (from api.video) of the video.
    ///   - videoType: The video type of the video (ie VOD or Live).
    ///   - token: The private token the video. If the video is public, this parameter can be omitted.
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
            self.sessionTokenUrl =  "\(liveUrl)/session"
        }

        self.mp4Url = "\(vodUrl)/mp4/source.mp4"
        self.thumbnailUrl = "\(vodUrl)/thumbnail.jpg"
    }
}

/// The video type of the video to play (ie VOD or Live).
public enum VideoType: String {
    /// Video type to play a video on demand.
    case vod = "https://vod.api.video/vod"
    /// Video type to play a live stream.
    case live = "https://live.api.video"
}
