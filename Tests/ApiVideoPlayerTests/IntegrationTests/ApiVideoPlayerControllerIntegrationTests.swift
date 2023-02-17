@testable import ApiVideoPlayer
import CoreMedia
import XCTest

final class ApiVideoPlayerControllerIntegrationTests: XCTestCase {
    func testValidVideoIdPlay() throws {
        let mockDelegate = MockedPlayerDelegate(testCase: self)
        let controller = ApiVideoPlayerController(
            videoOptions: VideoOptions(videoId: VideoId.validVideoId),
            delegates: [mockDelegate]
        )
        guard let ready = mockDelegate.expectationReady() else {
            throw MockDelegateError.playerEventDelegateError("Something whent wrong with mocked delegate")
        }
        guard let play = mockDelegate.expectationPlay() else {
            throw MockDelegateError.playerEventDelegateError("Something whent wrong with mocked delegate")
        }
        guard let error = mockDelegate.expectationError(true) else {
            throw MockDelegateError.playerEventDelegateError("Something whent wrong with mocked delegate")
        }
        wait(for: [ready], timeout: 10)
        controller.play()
        wait(for: [play], timeout: 2)
        wait(for: [error], timeout: 5)
    }

    func testValidVideoIdWithSetterPlay() throws {
        let mockDelegate = MockedPlayerDelegate(testCase: self)
        let controller = ApiVideoPlayerController(
            videoOptions: nil,
            delegates: [mockDelegate]
        )
        controller.videoOptions = VideoOptions(videoId: VideoId.validVideoId)
        guard let ready = mockDelegate.expectationReady() else {
            throw MockDelegateError.playerEventDelegateError("Something whent wrong with mocked delegate")
        }
        guard let play = mockDelegate.expectationPlay() else {
            throw MockDelegateError.playerEventDelegateError("Something whent wrong with mocked delegate")
        }
        guard let error = mockDelegate.expectationError(true) else {
            throw MockDelegateError.playerEventDelegateError("Something whent wrong with mocked delegate")
        }
        wait(for: [ready], timeout: 10)
        controller.play()
        wait(for: [play], timeout: 2)
        wait(for: [error], timeout: 5)
    }

    func testValidVideoIdPause() throws {
        let mockDelegate = MockedPlayerDelegate(testCase: self)
        let controller = ApiVideoPlayerController(
            videoOptions: VideoOptions(videoId: VideoId.validVideoId),
            delegates: [mockDelegate]
        )

        guard let ready = mockDelegate.expectationReady() else {
            throw MockDelegateError.playerEventDelegateError("Something whent wrong with mocked delegate")
        }
        guard let play = mockDelegate.expectationPlay() else {
            throw MockDelegateError.playerEventDelegateError("Something whent wrong with mocked delegate")
        }
        guard let pause = mockDelegate.expectationPause() else {
            throw MockDelegateError.playerEventDelegateError("Something whent wrong with mocked delegate")
        }
        guard let error = mockDelegate.expectationError(true) else {
            throw MockDelegateError.playerEventDelegateError("Something whent wrong with mocked delegate")
        }
        wait(for: [ready], timeout: 10)
        controller.play()
        wait(for: [play], timeout: 2)
        controller.pause()
        wait(for: [pause], timeout: 2)
        wait(for: [error], timeout: 5)
    }

    func testReturnOneEventOnMultiplePause() throws {
        let mockDelegate = MockedPlayerDelegate(testCase: self)
        let controller = ApiVideoPlayerController(
            videoOptions: VideoOptions(videoId: VideoId.validVideoId),
            delegates: [mockDelegate]
        )
        guard let ready = mockDelegate.expectationReady() else {
            throw MockDelegateError.playerEventDelegateError("Something whent wrong with mocked delegate")
        }
        guard let play = mockDelegate.expectationPlay() else {
            throw MockDelegateError.playerEventDelegateError("Something whent wrong with mocked delegate")
        }
        guard mockDelegate.expectationPause() != nil else {
            throw MockDelegateError.playerEventDelegateError("Something whent wrong with mocked delegate")
        }
        guard mockDelegate.expectationMultiplePause() != nil else {
            throw MockDelegateError.playerEventDelegateError("Something whent wrong with mocked delegate")
        }
        guard mockDelegate.expectationError(true) != nil else {
            throw MockDelegateError.playerEventDelegateError("Something whent wrong with mocked delegate")
        }
        wait(for: [ready], timeout: 5)
        controller.play()
        wait(for: [play], timeout: 2)
        controller.pause()
        controller.pause()

        waitForExpectations(timeout: 15, handler: nil)
    }

    func testDuration() throws {
        let mockDelegate = MockedPlayerDelegate(testCase: self)
        let controller = ApiVideoPlayerController(
            videoOptions: VideoOptions(videoId: VideoId.validVideoId),
            delegates: [mockDelegate]
        )
        guard mockDelegate.expectationReady() != nil else {
            throw MockDelegateError.playerEventDelegateError("Something whent wrong with mocked delegate")
        }
        guard mockDelegate.expectationError(true) != nil else {
            throw MockDelegateError.playerEventDelegateError("Something whent wrong with mocked delegate")
        }
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(controller.duration.seconds, 60.2)
    }

    func testWithVideoOptionsWithSetterDuration() throws {
        let mockDelegate = MockedPlayerDelegate(testCase: self)
        let controller = ApiVideoPlayerController(
            videoOptions: nil,
            delegates: [mockDelegate]
        )
        controller.videoOptions = VideoOptions(videoId: VideoId.validVideoId)
        guard mockDelegate.expectationReady() != nil else {
            throw MockDelegateError.playerEventDelegateError("Something whent wrong with mocked delegate")
        }
        guard mockDelegate.expectationError(true) != nil else {
            throw MockDelegateError.playerEventDelegateError("Something whent wrong with mocked delegate")
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(controller.duration.seconds, 60.2)
    }

    func testInvalidVideoId() throws {
        let mockDelegate = MockedPlayerDelegate(testCase: self)
        let controller = ApiVideoPlayerController(
            videoOptions: VideoOptions(videoId: VideoId.invalidVideoId),
            delegates: [mockDelegate]
        )
        guard mockDelegate.expectationReady(true) != nil else {
            throw MockDelegateError.playerEventDelegateError("Something whent wrong with mocked delegate")
        }
        guard mockDelegate.expectationError() != nil else {
            throw MockDelegateError.playerEventDelegateError("Something whent wrong with mocked delegate")
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}
