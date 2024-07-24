import Foundation

enum PlayerError: Error {
    case invalidUrl(String)
    case playbackFailed(String)
    case thumbnailDecodeFailed(URL)
}

// MARK: LocalizedError

extension PlayerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .invalidUrl(url):
            return "URL is not valid: \(url)"
        case let .playbackFailed(info):
            return "Failed to read video: \(info)"
        case let .thumbnailDecodeFailed(url):
            return "Thumbnail is not decodable: \(url)"
        }
    }
}
