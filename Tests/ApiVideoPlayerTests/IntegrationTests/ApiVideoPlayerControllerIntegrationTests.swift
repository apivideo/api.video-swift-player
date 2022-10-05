@testable import ApiVideoPlayer
import CoreMedia
import XCTest

@available(iOS 14.0, *)
final class ApiVideoPlayerControllerIntegrationTests: XCTestCase {
  private let validVideoId = "vi2G6Qr8ZVE67dWLNymk7qbc"
  private let invalidVideoId = "unknownVideoId"

  func testValidVideoIdPlay() throws {
    let expectation = self.expectation(description: "delegate is called 2 times")
    expectation.expectedFulfillmentCount = 2

    let events = PlayerEvents(
      didPrepare: { () in
        print("ready")
        expectation.fulfill()
      },
      didPlay: { () in
        print("play")
        expectation.fulfill()
      }
    )
    let controller = ApiVideoPlayerController(videoId: validVideoId, videoType: .vod, events: events)
    controller.play()
    waitForExpectations(timeout: 10, handler: nil)
  }

  func testValidVideoIdPause() throws {
    let completedExpectationPrepare = expectation(description: "Completed Prepare")
    let completedExpectationPlay = expectation(description: "Completed Play")
    let completedExpectationPause = expectation(description: "Completed Pause")
    let events = PlayerEvents(
      didPrepare: { () in
        print("ready")
        completedExpectationPrepare.fulfill()
      },
      didPause: { () in
        print("paused test")
        completedExpectationPause.fulfill()
      },
      didPlay: { () in
        print("play")
        completedExpectationPlay.fulfill()
      }
    )
    let controller = ApiVideoPlayerController(videoId: validVideoId, videoType: .vod, events: events)
    wait(for: [completedExpectationPrepare], timeout: 10)
    controller.play()
    wait(for: [completedExpectationPlay], timeout: 2)
    controller.pause()
    wait(for: [completedExpectationPause], timeout: 2)
  }

  func testReturnOneEventOnMultiplePause() throws {
    let completedExpectationPrepare = expectation(description: "Completed Prepare")
    let expectationPause = self.expectation(description: "pause is called 1 times")
    expectationPause.expectedFulfillmentCount = 1
    let events = PlayerEvents(
      didPrepare: { () in
        print("ready")
        completedExpectationPrepare.fulfill()
      },
      didPause: { () in
        print("paused")
        expectationPause.fulfill()
      }
    )
    let controller = ApiVideoPlayerController(videoId: validVideoId, videoType: .vod, events: events)
    wait(for: [completedExpectationPrepare], timeout: 10)
    controller.play()
    controller.pause()
    controller.pause()
    waitForExpectations(timeout: 10, handler: nil)
  }

  func testDuration() throws {
    let expectation = self.expectation(description: "delegate is called 1 times")
    expectation.expectedFulfillmentCount = 1
    let events = PlayerEvents(
      didPrepare: { () in
        print("ready")
        expectation.fulfill()
      },
      didError: { error in
        print("error : \(error)")
        expectation.fulfill()
        XCTFail("\(error)")
      }
    )
    var duration: Double = 0
    let controller = ApiVideoPlayerController(videoId: validVideoId, videoType: .vod, events: events)
    waitForExpectations(timeout: 10, handler: nil)
    duration = controller.duration.seconds
    XCTAssertEqual(duration, 60.2)
  }

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
    _ = ApiVideoPlayerController(videoId: self.invalidVideoId, videoType: .vod, events: events)
    waitForExpectations(timeout: 10, handler: nil)
  }

}
