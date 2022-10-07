@testable import ApiVideoPlayer
import CoreMedia
import XCTest

@available(iOS 14.0, *)
final class ApiVideoPlayerControllerIntegrationTests: XCTestCase {
  private let validVideoId = "vi2G6Qr8ZVE67dWLNymk7qbc"
  private let invalidVideoId = "unknownVideoId"

  func testValidVideoIdPlay() throws {
    let completedExpectationPrepare = expectation(description: "Completed Prepare")
    let completedExpectationPlay = expectation(description: "Completed Play")
    let errorExpectation = expectation(description: "error is called")
    errorExpectation.isInverted = true
    let events = PlayerEvents(
      didPrepare: { () in
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
    let controller = ApiVideoPlayerController(videoId: validVideoId, videoType: .vod, events: events)
    wait(for: [completedExpectationPrepare], timeout: 10)
    controller.play()
    wait(for: [completedExpectationPlay], timeout: 2)
    wait(for: [errorExpectation], timeout: 5)
  }

  func testValidVideoIdPause() throws {
    let completedExpectationPrepare = expectation(description: "Completed Prepare")
    let completedExpectationPlay = expectation(description: "Completed Play")
    let completedExpectationPause = expectation(description: "Completed Pause")
    let errorExpectation = expectation(description: "error is called")
    errorExpectation.isInverted = true
    let events = PlayerEvents(
      didPrepare: { () in
        print("ready")
        completedExpectationPrepare.fulfill()
      },
      didPause: { () in
        print("paused")
        completedExpectationPause.fulfill()
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
    let controller = ApiVideoPlayerController(videoId: validVideoId, videoType: .vod, events: events)
    wait(for: [completedExpectationPrepare], timeout: 10)
    controller.play()
    wait(for: [completedExpectationPlay], timeout: 2)
    controller.pause()
    wait(for: [completedExpectationPause], timeout: 2)
    wait(for: [errorExpectation], timeout: 5)
  }

  func testReturnOneEventOnMultiplePause() throws {
    let completedExpectationPrepare = expectation(description: "Completed Prepare")
    let expectationPause = self.expectation(description: "pause is called")
    let errorExpectation = expectation(description: "error is called")
    errorExpectation.isInverted = true
    let events = PlayerEvents(
      didPrepare: { () in
        print("ready")
        completedExpectationPrepare.fulfill()
      },
      didPause: { () in
        print("paused")
        expectationPause.fulfill()
      },
      didError: { error in
        print("error\(error)")
        errorExpectation.fulfill()
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
    let prepareExpectation = self.expectation(description: "prepare is called")
    let errorExpectation = self.expectation(description: "error is called")
    errorExpectation.isInverted = true
    let events = PlayerEvents(
      didPrepare: { () in
        print("ready")
        prepareExpectation.fulfill()
      },
      didError: { error in
        print("error : \(error)")
        errorExpectation.fulfill()
      }
    )
    let controller = ApiVideoPlayerController(videoId: validVideoId, videoType: .vod, events: events)
    waitForExpectations(timeout: 10, handler: nil)
    XCTAssertEqual(controller.duration.seconds, 60.2)
  }

  func testInvalidVideoId() throws {
    let prepareExpectation = expectation(description: "prepare is called")
    prepareExpectation.isInverted = true
    let errorExpectation = expectation(description: "error is called")
    let events = PlayerEvents(
      didPrepare: { () in
        print("ready")
        prepareExpectation.fulfill()
      },
      didError: { error in
        print("error : \(error)")
        errorExpectation.fulfill()
      }
    )
    _ = ApiVideoPlayerController(videoId: self.invalidVideoId, videoType: .vod, events: events)
    waitForExpectations(timeout: 10, handler: nil)
  }

}
