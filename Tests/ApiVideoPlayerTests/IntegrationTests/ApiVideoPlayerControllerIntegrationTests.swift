@testable import ApiVideoPlayer
import CoreMedia
import XCTest

final class ApiVideoPlayerControllerIntegrationTests: XCTestCase {

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
    let controller = ApiVideoPlayerController(videoId: VideoId.validVideoId, videoType: .vod, events: events)
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
    let controller = ApiVideoPlayerController(videoId: VideoId.validVideoId, videoType: .vod, events: events)
    wait(for: [completedExpectationPrepare], timeout: 10)
    controller.play()
    wait(for: [completedExpectationPlay], timeout: 2)
    controller.pause()
    wait(for: [completedExpectationPause], timeout: 2)
    wait(for: [errorExpectation], timeout: 5)
  }

  func testReturnOneEventOnMultiplePause() throws {
    var didCalled = false
    let completedExpectationPrepare = expectation(description: "Completed Prepare")
    let expectationPause = self.expectation(description: "pause is called")
    let secondExpectationPause = self.expectation(description: "2nd pause is called")
    secondExpectationPause.isInverted = true
    let errorExpectation = expectation(description: "error is called")
    errorExpectation.isInverted = true
    let events = PlayerEvents(
      didPrepare: { () in
        print("ready")
        completedExpectationPrepare.fulfill()
      },
      didPause: { () in
        print("paused")
        if !didCalled {
          didCalled = true
          expectationPause.fulfill()
        } else {
          secondExpectationPause.fulfill()
        }

      },
      didError: { error in
        print("error\(error)")
        errorExpectation.fulfill()
      }
    )
    let controller = ApiVideoPlayerController(videoId: VideoId.validVideoId, videoType: .vod, events: events)
    wait(for: [completedExpectationPrepare], timeout: 10)
    controller.play()
    controller.pause()
    controller.pause()
    waitForExpectations(timeout: 15, handler: nil)
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
    let controller = ApiVideoPlayerController(videoId: VideoId.validVideoId, videoType: .vod, events: events)
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
    _ = ApiVideoPlayerController(videoId: VideoId.invalidVideoId, videoType: .vod, events: events)
    waitForExpectations(timeout: 10, handler: nil)
  }

}
