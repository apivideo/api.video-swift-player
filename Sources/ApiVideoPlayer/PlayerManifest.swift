import Foundation
public struct PlayerManifest: Codable {
    var id: String
    var title: String
    var video: Video
    var panoramic: Bool?
    var live: Bool?
}

public struct Video: Codable {
    var poster: String
    var src: String
    var mp4: String?
}

public struct TokenSession: Codable {
    var sessionToken: String
}
