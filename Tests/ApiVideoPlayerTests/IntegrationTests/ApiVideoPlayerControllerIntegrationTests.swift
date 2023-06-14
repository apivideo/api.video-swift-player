import ApiVideoClient
@testable import ApiVideoPlayer
import CoreMedia
import XCTest

final class ApiVideoPlayerControllerIntegrationTests: XCTestCase {
    func testValidVideoIdPlay() throws {
        let mockDelegate = MockedPlayerDelegate(testCase: self)
        let ready = mockDelegate.expectationReady()
        let play = mockDelegate.expectationPlay()
        let error = mockDelegate.expectationError(true)

        let controller = ApiVideoPlayerController(
            videoOptions: VideoOptions(videoId: VideoId.validVideoId, videoType: .vod),
            delegates: [mockDelegate]
        )

        wait(for: [ready], timeout: 10)
        controller.play()
        wait(for: [play], timeout: 2)
        wait(for: [error], timeout: 5)
    }

    func testValidVideoIdWithSetterPlay() throws {
        let mockDelegate = MockedPlayerDelegate(testCase: self)
        let ready = mockDelegate.expectationReady()
        let play = mockDelegate.expectationPlay()
        let error = mockDelegate.expectationError(true)

        let controller = ApiVideoPlayerController(
            videoOptions: nil,
            delegates: [mockDelegate]
        )
        controller.videoOptions = VideoOptions(videoId: VideoId.validVideoId, videoType: .vod)

        wait(for: [ready], timeout: 10)
        controller.play()
        wait(for: [play], timeout: 2)
        wait(for: [error], timeout: 5)
    }

    func testValidVideoIdPause() throws {
        let mockDelegate = MockedPlayerDelegate(testCase: self)
        let ready = mockDelegate.expectationReady()
        let play = mockDelegate.expectationPlay()
        let pause = mockDelegate.expectationPause()
        let error = mockDelegate.expectationError(true)

        let controller = ApiVideoPlayerController(
            videoOptions: VideoOptions(videoId: VideoId.validVideoId, videoType: .vod),
            delegates: [mockDelegate]
        )

        wait(for: [ready], timeout: 10)
        controller.play()
        wait(for: [play], timeout: 2)
        controller.pause()
        wait(for: [pause], timeout: 2)
        wait(for: [error], timeout: 5)
    }

    func testReturnOneEventOnMultiplePause() throws {
        let mockDelegate = MockedPlayerDelegate(testCase: self)
        let ready = mockDelegate.expectationReady()
        let play = mockDelegate.expectationPlay()
        _ = mockDelegate.expectationPause()
        _ = mockDelegate.expectationMultiplePause()
        _ = mockDelegate.expectationError(true)

        let controller = ApiVideoPlayerController(
            videoOptions: VideoOptions(videoId: VideoId.validVideoId, videoType: .vod),
            delegates: [mockDelegate]
        )

        wait(for: [ready], timeout: 5)
        controller.play()
        wait(for: [play], timeout: 2)
        controller.pause()
        controller.pause()

        waitForExpectations(timeout: 15, handler: nil)
    }

    func testDuration() throws {
        let mockDelegate = MockedPlayerDelegate(testCase: self)
        _ = mockDelegate.expectationReady()
        _ = mockDelegate.expectationError(true)

        let controller = ApiVideoPlayerController(
            videoOptions: VideoOptions(videoId: VideoId.validVideoId, videoType: .vod),
            delegates: [mockDelegate]
        )

        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(controller.duration.seconds, 60.2)
    }

    func testWithVideoOptionsWithSetterDuration() throws {
        let mockDelegate = MockedPlayerDelegate(testCase: self)
        _ = mockDelegate.expectationReady()
        _ = mockDelegate.expectationError(true)

        let controller = ApiVideoPlayerController(
            videoOptions: nil,
            delegates: [mockDelegate]
        )
        controller.videoOptions = VideoOptions(videoId: VideoId.validVideoId, videoType: .vod)

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(controller.duration.seconds, 60.2)
    }

    func testInvalidVideoId() throws {
        let mockDelegate = MockedPlayerDelegate(testCase: self)
        _ = mockDelegate.expectationReady(true)
        _ = mockDelegate.expectationError()

        let controller = ApiVideoPlayerController(
            videoOptions: VideoOptions(videoId: VideoId.invalidVideoId, videoType: .vod),
            delegates: [mockDelegate]
        )

        waitForExpectations(timeout: 5, handler: nil)
    }

    @available(iOS 13.0, *)
    func testValidPrivateVideoIdPlay() async throws {
        let privateToken = try await Utils.getPrivateToken(videoId: VideoId.privateVideoId)

        let mockDelegate = MockedPlayerDelegate(testCase: self)
        let ready = mockDelegate.expectationReady()
        let play = mockDelegate.expectationPlay()
        let expectationError = mockDelegate.expectationError(true)

        let controller = ApiVideoPlayerController(
            videoOptions: VideoOptions(videoId: VideoId.privateVideoId, videoType: .vod, token: privateToken),
            delegates: [mockDelegate]
        )

        self.wait(for: [ready], timeout: 10)
        controller.play()
        self.wait(for: [play], timeout: 2)
        self.wait(for: [expectationError], timeout: 15)
    }
}
