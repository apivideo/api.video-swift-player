@testable import ApiVideoPlayer
import CoreMedia
import XCTest
#if !os(macOS)

/// Integration tests with connection to api.video
final class ApiVideoPlayerViewIntegrationTests: XCTestCase {
    /// Assert that a valid video id is correctly played
    /// Check that the PlayerEvents are correctly called: didPrepare, didPlay
    func testValidVideoIdPlay() throws {
        let mockDelegate = MockedPlayerDelegate(testCase: self)
        _ = mockDelegate.expectationReady()
        _ = mockDelegate.expectationPlay()
        _ = mockDelegate.expectationError(true)

        let playerView = ApiVideoPlayerView(
            frame: .zero,
            videoOptions: VideoOptions(videoId: VideoId.validVideoId)
        )
        playerView.addDelegate(mockDelegate)
        playerView.play()

        waitForExpectations(timeout: 15, handler: nil)
    }

    /// Assert that didError is triggered when an invalid video id is passed
    func testInvalidVideoId() throws {
        let mockDelegate = MockedPlayerDelegate(testCase: self)
        _ = mockDelegate.expectationReady(true)
        _ = mockDelegate.expectationError()

        let playerView = ApiVideoPlayerView(
            frame: .zero,
            videoOptions: VideoOptions(videoId: VideoId.invalidVideoId)
        )
        playerView.addDelegate(mockDelegate)

        waitForExpectations(timeout: 10, handler: nil)
    }
}
#endif
