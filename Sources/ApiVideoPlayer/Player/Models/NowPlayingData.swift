import CoreMedia
import Foundation

struct NowPlayingData {
    let duration: CMTime
    let currentTime: CMTime
    let isLive: Bool
    let thumbnailUrl: String?
    let title: String? = nil
    let playbackRate: Float
}
