@testable import ApiVideoPlayer
import CoreMedia
import XCTest

/// Integration tests with connection to api.video
@available(iOS 14.0, *)
final class ApiVideoPlayerIntegrationTests: XCTestCase {
  private let validVideoId = "vi2G6Qr8ZVE67dWLNymk7qbc"
  private let invalidVideoId = "unknownVideoId"

  /// Assert that a valid video id is correctly played
  /// Check that the PlayerEvents are correctly called: didPrepare, didPlay
  func testValidVideoIdPlay() throws {
    let completedExpectationPrepare = expectation(description: "Completed Prepare")
    let completedExpectationPlay = expectation(description: "Completed Play")
    var didPlay = false
    let events = PlayerEvents(
      didPrepare: { () in
        print("ready")
        completedExpectationPrepare.fulfill()
      },
      didPlay: { () in
        print("play")
        didPlay = true
        completedExpectationPlay.fulfill()
      }
    )
    let playerView = ApiVideoPlayerView(
      frame: .zero,
      videoId: validVideoId,
      videoType: VideoType.vod /* only .vod is supported */,
      events: events
    )
    wait(for: [completedExpectationPrepare], timeout: 10)
    print(playerView.duration.seconds)
    playerView.play()
    wait(for: [completedExpectationPlay], timeout: 3)
    XCTAssertTrue(didPlay, "The video must be played")
  }

  /// Assert that a valid video id is correctly played
  /// Check that the PlayerEvents are correctly called: didPrepare, didPlay
  func testValidVideoIdPause() throws {
    let completedExpectationPrepare = expectation(description: "Completed Prepare")
    let completedExpectationPlay = expectation(description: "Completed Play")
    let completedExpectationPause = expectation(description: "Completed Pause")
    var didPause = false
    let events = PlayerEvents(
      didPrepare: { () in
        print("ready")
        completedExpectationPrepare.fulfill()
      },
      didPause: { () in
        print("paused test")
        didPause = true
        completedExpectationPause.fulfill()
      },
      didPlay: { () in
        print("play")
        completedExpectationPlay.fulfill()
      }
    )
    let playerView = ApiVideoPlayerView(
      frame: .zero,
      videoId: validVideoId,
      videoType: VideoType.vod /* only .vod is supported */,
      events: events
    )
    wait(for: [completedExpectationPrepare], timeout: 10)
    print(playerView.duration.seconds)
    playerView.play()
    wait(for: [completedExpectationPlay], timeout: 3)
    playerView.pause()
    wait(for: [completedExpectationPause], timeout: 3)
    XCTAssertTrue(didPause, "The video must be paused")
  }

  /// Assert that the duration of the video is the expected duration
  /// Retrieve the validVideoId video and check its duration
  func testDuration() throws {
    let completedExpectation = expectation(description: "Completed")
    let events = PlayerEvents(
      didPrepare: { () in
        print("ready")
        completedExpectation.fulfill()
      },
      didError: { error in
        print("error : \(error)")
        completedExpectation.fulfill()
        XCTFail("\(error)")
      }
    )
    var duration: Double = 0
    let playerView = ApiVideoPlayerView(
      frame: .zero,
      videoId: validVideoId,
      videoType: VideoType.vod /* only .vod is supported */,
      events: events
    )
    waitForExpectations(timeout: 10, handler: nil)
    duration = playerView.duration.seconds
    XCTAssertEqual(duration, 60.2)

  }

  /// Assert that didError is triggered when an invalid video id is passed
  func testInvalidVideoId() throws {
    let completedExpectation = expectation(description: "Completed")
    let events = PlayerEvents(
      didPrepare: { () in
        print("ready")
        XCTFail("Should return didError")
      },
      didError: { error in
        print("error : \(error)")
        completedExpectation.fulfill()
        XCTAssertNotNil(error, "\(error)")
      }
    )
    let playerView = ApiVideoPlayerView(
      frame: .zero,
      videoId: invalidVideoId,
      videoType: VideoType.vod /* only .vod is supported */,
      events: events
    )
    // playerView.play()
    waitForExpectations(timeout: 10, handler: nil)
  }
}
