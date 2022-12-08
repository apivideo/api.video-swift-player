@testable import ApiVideoPlayer
import CoreMedia
import XCTest
#if !os(macOS)

/// Integration tests with connection to api.video
final class ApiVideoPlayerViewIntegrationTests: XCTestCase {

    /// Assert that a valid video id is correctly played
    /// Check that the PlayerEvents are correctly called: didPrepare, didPlay
    func testValidVideoIdPlay() throws {
        let completedExpectationPrepare = expectation(description: "Completed Prepare")
        let completedExpectationPlay = expectation(description: "Completed Play")
        let errorExpectation = expectation(description: "error is called")
        errorExpectation.isInverted = true
        let events = PlayerEvents(
            didReady: { () in
                print("ready")
                completedExpectationPrepare.fulfill()
            },
            didPlay: { () in
                print("play")
                completedExpectationPlay.fulfill()
            },
            didError: { error in
                print("error\(error)")
                errorExpectation.fulfill()
            }
        )
        let playerView = ApiVideoPlayerView(
            frame: .zero,
            videoId: VideoId.validVideoId,
            videoType: VideoType.vod /* only .vod is supported */,
            events: events
        )
        playerView.play()
        waitForExpectations(timeout: 15, handler: nil)
    }

    /// Assert that didError is triggered when an invalid video id is passed
    func testInvalidVideoId() throws {
        let prepareExpectation = expectation(description: "prepare is called")
        prepareExpectation.isInverted = true
        let errorExpectation = expectation(description: "error is called")
        let events = PlayerEvents(
            didReady: { () in
                print("ready")
                prepareExpectation.fulfill()
            },
            didError: { error in
                print("error : \(error)")
                errorExpectation.fulfill()
            }
        )
        let playerView = ApiVideoPlayerView(
            frame: .zero,
            videoId: VideoId.invalidVideoId,
            videoType: VideoType.vod /* only .vod is supported */,
            events: events
        )
        waitForExpectations(timeout: 10, handler: nil)
    }
}
#endif
