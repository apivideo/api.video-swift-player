import CoreMedia
import Foundation

struct NowPlayingData {
    var duration: CMTime?
    var currentTime: CMTime?
    var thumbnailUrl: String?
    var isLive: Bool?
    var title: String?
}
