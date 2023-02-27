import Foundation

public struct VideoOptions {
    public let videoId: String
    public let videoType: VideoType
    public let token: String?

    private var baseUrl = ""
    private var vodUrl = ""
    private var liveUrl = ""

    public init(videoId: String, videoType: VideoType, token: String? = nil) {
        self.videoId = videoId
        self.videoType = videoType
        self.token = token

        baseUrl = "\(videoType.rawValue)/\(videoId)"
        vodUrl = baseUrl
        liveUrl = "\(videoType.rawValue)"
        if let token = token {
            vodUrl.append("/token/\(token)")
            liveUrl.append("/private/\(token)")
        }
        liveUrl.append("/\(videoId)")
    }

    public var hlsManifestUrl: String {
        if videoType == .vod {
            return "\(vodUrl)/hls/manifest.m3u8"
        } else {
            return "\(liveUrl).m3u8"
        }
    }

    public var sessionTokenUrl: String {
        if videoType == .vod {
            return "\(vodUrl)/session"
        } else {
            return hlsManifestUrl
        }
    }

    public var mp4Url: String {
        return "\(vodUrl)/mp4/source.mp4"
    }

    public var thumbnailUrl: String {
        return "\(vodUrl)/thumbnail.jpg"
    }

}

public enum VideoType: String {
    case vod = "https://vod.api.video/vod"
    case live = "https://live.api.video"
}
