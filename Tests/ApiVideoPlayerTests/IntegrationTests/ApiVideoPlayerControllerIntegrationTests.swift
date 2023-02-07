@testable import ApiVideoPlayer
import CoreMedia
import XCTest

final class ApiVideoPlayerControllerIntegrationTests: XCTestCase, PlayerEventsDelegate {

    func testValidVideoIdPlay() throws {
        let completedExpectationPrepare = expectation(description: "Completed Prepare")
        let completedExpectationPlay = expectation(description: "Completed Play")
        let errorExpectation = expectation(description: "error is called")
        errorExpectation.isInverted = true

        let controllerEvent = ApiVideoPlayerControllerEvent(
            videoTypeDidChanged: { () in
                print("test videoTypeDidChanged")
            }
        )
        let controller = ApiVideoPlayerController(
            videoOptions: VideoOptions(videoId: VideoId.validVideoId),
            mcDelegate: self,
            playerControllerEvent: controllerEvent
        )
        wait(for: [completedExpectationPrepare], timeout: 10)
        controller.play()
        wait(for: [completedExpectationPlay], timeout: 2)
        wait(for: [errorExpectation], timeout: 5)
    }

    func testValidVideoIdWithSetterPlay() throws {
        let completedExpectationPrepare = expectation(description: "Completed Prepare")
        let completedExpectationPlay = expectation(description: "Completed Play")
        let errorExpectation = expectation(description: "error is called")
        errorExpectation.isInverted = true

        let controllerEvent = ApiVideoPlayerControllerEvent(
            videoTypeDidChanged: { () in
                print("test videoTypeDidChanged")
            }
        )
        let controller = ApiVideoPlayerController(
            videoOptions: nil,
            mcDelegate: self,
            playerControllerEvent: controllerEvent
        )
        controller.videoOptions = VideoOptions(videoId: VideoId.validVideoId)
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

        let controllerEvent = ApiVideoPlayerControllerEvent(
            videoTypeDidChanged: { () in
                print("test videoTypeDidChanged")
            }
        )
        let controller = ApiVideoPlayerController(
            videoOptions: VideoOptions(videoId: VideoId.validVideoId),
            mcDelegate: self,
            playerControllerEvent: controllerEvent
        )
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

        let controllerEvent = ApiVideoPlayerControllerEvent(
            videoTypeDidChanged: { () in
                print("test videoTypeDidChanged")
            }
        )
        let controller = ApiVideoPlayerController(
            videoOptions: VideoOptions(videoId: VideoId.validVideoId),
            mcDelegate: self,
            playerControllerEvent: controllerEvent
        )
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

        let controller = ApiVideoPlayerController(
            videoOptions: VideoOptions(videoId: VideoId.validVideoId),
            mcDelegate: self,
            playerControllerEvent: controllerEvent
        )
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(controller.duration.seconds, 60.2)
    }

    func testWithVideoOptionsWithSetterDuration() throws {
        let prepareExpectation = self.expectation(description: "prepare is called")
        let errorExpectation = self.expectation(description: "error is called")
        errorExpectation.isInverted = true
        let controllerEvent = ApiVideoPlayerControllerEvent(
            videoTypeDidChanged: { () in
                print("test videoTypeDidChanged")
            }
        )
        let controller = ApiVideoPlayerController(
            videoOptions: nil,
            mcDelegate: self,
            playerControllerEvent: controllerEvent
        )

        controller.videoOptions = VideoOptions(videoId: VideoId.validVideoId)
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(controller.duration.seconds, 60.2)
    }

    func testInvalidVideoId() throws {
        let prepareExpectation = expectation(description: "prepare is called")
        prepareExpectation.isInverted = true
        let errorExpectation = expectation(description: "error is called")

        let controllerEvent = ApiVideoPlayerControllerEvent(
            videoTypeDidChanged: { () in
                print("test videoTypeDidChanged")
            }
        )
        _ = ApiVideoPlayerController(
            videoOptions: VideoOptions(videoId: VideoId.invalidVideoId),
            mcDelegate: self,
            playerControllerEvent: controllerEvent
        )
        waitForExpectations(timeout: 10, handler: nil)
    }
}
