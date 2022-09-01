@testable import ApiVideoPlayer
import XCTest

/// Integration tests with connection to api.video
@available(iOS 14.0, *)
final class ApiVideoPlayerIntegrationTests: XCTestCase {
    private let validVideoId = "vi2G6Qr8ZVE67dWLNymk7qbc"
    private let invalidVideoId = "unknownVideoId"

    /// Assert that a valid video id is correctly played
    /// Check that the PlayerEvents are correctly called: didPrepare, didPlay, didEnd,...
    func testValidVideoId() throws {
        // TODO:
    }

    /// Assert that the duration of the video is the expected duration
    /// Retrieve the validVideoId video and check its duration
    func testDuration() throws {
        let duration: Double = 0 // TODO:
        XCTAssertEqual(duration, 60.2)
    }

    /// Assert that didError is triggered when an invalid video id is passed
    func testInvalidVideoId() throws {
        // TODO:
    }
}
