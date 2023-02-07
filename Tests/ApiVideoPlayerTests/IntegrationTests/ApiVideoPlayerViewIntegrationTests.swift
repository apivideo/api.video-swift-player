@testable import ApiVideoPlayer
import CoreMedia
import XCTest
#if !os(macOS)

/// Integration tests with connection to api.video
final class ApiVideoPlayerViewIntegrationTests: XCTestCase, PlayerEventsDelegate {
    func didPrepare() {}

    func didReady() {}

    func didPause() {}

    func didPlay() {}

    func didReplay() {}

    func didMute() {}

    func didUnMute() {}

    func didLoop() {}

    func didSetVolume(_: Float) {}

    func didSeek(_: CMTime, _: CMTime) {}

    func didEnd() {}

    func didError(_: Error) {}

    func didVideoSizeChanged(_: CGSize) {}

    /// Assert that a valid video id is correctly played
    /// Check that the PlayerEvents are correctly called: didPrepare, didPlay
    func testValidVideoIdPlay() throws {
        let completedExpectationPrepare = expectation(description: "Completed Prepare")
        let completedExpectationPlay = expectation(description: "Completed Play")
        let errorExpectation = expectation(description: "error is called")
        errorExpectation.isInverted = true

        let playerView = ApiVideoPlayerView(
            frame: .zero,
            videoOptions: VideoOptions(videoId: VideoId.validVideoId)
        )
        playerView.play()
        waitForExpectations(timeout: 15, handler: nil)
    }

    /// Assert that didError is triggered when an invalid video id is passed
    func testInvalidVideoId() throws {
        let prepareExpectation = expectation(description: "prepare is called")
        prepareExpectation.isInverted = true
        let errorExpectation = expectation(description: "error is called")
        let playerView = ApiVideoPlayerView(
            frame: .zero,
            videoOptions: VideoOptions(videoId: VideoId.invalidVideoId)
        )
        waitForExpectations(timeout: 10, handler: nil)
    }
}
#endif
