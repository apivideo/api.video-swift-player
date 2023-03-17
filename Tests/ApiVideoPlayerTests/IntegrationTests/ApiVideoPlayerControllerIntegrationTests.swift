@testable import ApiVideoPlayer
import CoreMedia
import XCTest
import ApiVideoClient

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

    func testValidPrivateVideoIdPlay() async throws {
        let privateToken = try await getPrivateToken(videoId: VideoId.privateVideoId)

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

    private func getPrivateToken(videoId: String) async throws -> String {
        // Init ApiVideoClient
        try XCTSkipIf(Parameters.apiKey == "INTEGRATION_TESTS_API_KEY", "Can't get API key")
        ApiVideoClient.apiKey = Parameters.apiKey
        try? ApiVideoClient.setApplicationName(name: "player-integration-tests", version: "0")

        // Get token
        return try await withCheckedThrowingContinuation { continuation in
            VideosAPI.get(videoId: VideoId.privateVideoId) { video, error in
                if let error = error {
                    print("Can't get video: \(error)")
                    continuation.resume(throwing: error)
                    return
                }
                guard let player = video?.assets?.player else {
                    print("Can't get assets")
                    continuation.resume(throwing: PlayerError.sessionTokenError("Can't get assets"))
                    return
                }

                continuation.resume(returning: player.components(separatedBy: "=")[1])
            }
        }
    }
}
