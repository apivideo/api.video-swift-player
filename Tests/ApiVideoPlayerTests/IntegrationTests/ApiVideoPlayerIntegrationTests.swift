@testable import ApiVideoPlayer
import XCTest
import CoreMedia


/// Integration tests with connection to api.video
@available(iOS 14.0, *)
final class ApiVideoPlayerIntegrationTests: XCTestCase {
    private let validVideoId = "vi2G6Qr8ZVE67dWLNymk7qbc"
    private let invalidVideoId = "unknownVideoId"

    /// Assert that a valid video id is correctly played
    /// Check that the PlayerEvents are correctly called: didPrepare, didPlay, didEnd,...
    func testValidVideoId() throws {
        let completedExpectationPrepare = expectation(description: "Completed Prepare")
        let completedExpectationPlay = expectation(description: "Completed Play")
        let completedExpectationPause = expectation(description: "Completed Pause")
        let completedExpectationSeek = expectation(description: "Completed Seek")
        let completedExpectationEnd = expectation(description: "Completed End")
        var didPrepare = false
        var didPlay = false
        var didPause = false
        var didSeek = false
        var didEnd = false
        let events = PlayerEvents(
            didPrepare: {() in
                print("ready")
                didPrepare = true
                completedExpectationPrepare.fulfill()
            },
            didPause: {() in
                print("paused test")
                if(!didPause){
                    didPause = true
                    completedExpectationPause.fulfill()
                }
            },
            didPlay: {() in
                print("play")
                if(!didPlay){
                    didPlay = true
                    completedExpectationPlay.fulfill()
                }
            },
            didReplay: {() in
                print("video replayed")
            },
            didLoop: {() in
                print("video replayed from loop")
            },
            didSetVolume: {(volume) in
                print("volume set to : \(volume)")
            },
            didSeek: {(from, to)in
                print("seek from : \(from), to: \(to)")
                didSeek = true
                completedExpectationSeek.fulfill()
            },
            didEnd: {() in
                print("Ended")
                didEnd = true
                completedExpectationEnd.fulfill()
            }
        )
        let playerView = ApiVideoPlayerView(frame: .zero, videoId: validVideoId, videoType: VideoType.vod /* only .vod is supported */, events: events)
        wait(for: [completedExpectationPrepare], timeout: 10)
        playerView.play()
        wait(for: [completedExpectationPlay], timeout: 3)
        playerView.pause()
        wait(for: [completedExpectationPause], timeout: 3)
        playerView.seek(to: CMTime(seconds: 59.0, preferredTimescale: 100))
        wait(for: [completedExpectationSeek], timeout: 3)
        playerView.play()
        wait(for: [completedExpectationEnd], timeout: 9)
        
        XCTAssertTrue(didEnd)
        XCTAssertTrue(didSeek)
        XCTAssertTrue(didPause)
        XCTAssertTrue(didPlay)
        XCTAssertTrue(didPrepare)

    }

    /// Assert that the duration of the video is the expected duration
    /// Retrieve the validVideoId video and check its duration
    func testDuration() throws {
        let completedExpectation = expectation(description: "Completed")
        let events = PlayerEvents(
            didPrepare: {() in
                print("ready")
                completedExpectation.fulfill()
            },
            didError: {(error) in
                print("error : \(error)")
                completedExpectation.fulfill()
                XCTFail("should work")
            }
        )
        var duration: Double = 0
        let playerView = ApiVideoPlayerView(frame: .zero, videoId: validVideoId, videoType: VideoType.vod /* only .vod is supported */, events: events)
        waitForExpectations(timeout: 10, handler: nil)
        duration = playerView.duration.seconds
        XCTAssertEqual(duration, 60.2)
        
    }

    /// Assert that didError is triggered when an invalid video id is passed
    func testInvalidVideoId() throws {
        let completedExpectation = expectation(description: "Completed")
        let events = PlayerEvents(
            didPrepare: {() in
                print("ready")
                XCTFail("Should return didError")
            },
            didError: {(error) in
                print("error : \(error)")
                completedExpectation.fulfill()
                XCTAssertNotNil(error, "error should not be nil")
            }
        )
        let playerView = ApiVideoPlayerView(frame: .zero, videoId: invalidVideoId, videoType: VideoType.vod /* only .vod is supported */, events: events)
        //playerView.play()
        waitForExpectations(timeout: 10, handler: nil)
    }
}
