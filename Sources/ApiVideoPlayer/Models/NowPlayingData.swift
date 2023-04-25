import CoreMedia
import Foundation

struct NowPlayingData {
    let duration: CMTime
    let currentTime: CMTime
    let isLive: Bool
    let thumbnailUrl: String?
    let title: String?

    init(duration: CMTime, currentTime: CMTime, isLive: Bool, thumbnailUrl: String?, title: String? = nil) {
        self.duration = duration
        self.currentTime = currentTime
        self.isLive = isLive
        self.thumbnailUrl = thumbnailUrl
        self.title = title
    }
}
