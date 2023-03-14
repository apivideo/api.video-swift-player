@testable import ApiVideoPlayer
import CoreMedia
import XCTest
/// Unit tests on PlayerController without connection to api.video
/// The connection is mocked with MockedTasksExecutor
class ApiVideoPlayerUnitTests: XCTestCase {

    /// Assert that didError is not called if the JSON is valid
    func testWithValidSessionRequest() throws {
        Utils.generateResource(resource: "responseSuccess")
        let mockDelegate = MockedPlayerDelegate(testCase: self)
        _ = mockDelegate.expectationPrepare()

        let controller = ApiVideoPlayerController(
            videoOptions: VideoOptions(
                videoId: "vi2H6m1D23s0lGQnYZJyIp7e",
                videoType: .vod,
                token: "729d939a-b546-4e39-bd15-4dc8123e5ee3"
            ),
            delegates: [mockDelegate],
            taskExecutor: MockedTasksExecutor.self
        )

        waitForExpectations(timeout: 5, handler: nil)
    }

    /// Assert that didError is not called if the JSON is valid
    func testWithNilToken() throws {
        Utils.generateResource(resource: "responseSuccess")
        let mockDelegate = MockedPlayerDelegate(testCase: self)
        _ = mockDelegate.expectationPrepare()

        let controller = ApiVideoPlayerController(
            videoOptions: VideoOptions(
                videoId: "vi2H6m1D23s0lGQnYZJyIp7e",
                videoType: .vod,
                token: nil
            ),
            delegates: [mockDelegate],
            taskExecutor: MockedTasksExecutor.self
        )

        waitForExpectations(timeout: 15, handler: nil)
    }

    /// Assert didError is called if the JSON is invalid (syntax error or missing values)
    func testWithInvalidSessionRequestResponse() throws {
        Utils.generateResource(resource: "responseError")
        let mockDelegate = MockedPlayerDelegate(testCase: self)
        _ = mockDelegate.expectationPrepare(true)

        let controller = ApiVideoPlayerController(
            videoOptions: VideoOptions(
                videoId: "vi18RL1kvZlDRdzk7Mas59HT",
                videoType: .vod,
                token: "729d939a-b546-4e39-bd15-4dc8123e5ee3"
            ),
            delegates: [mockDelegate],
            taskExecutor: MockedTasksExecutor.self
        )

        waitForExpectations(timeout: 5, handler: nil)
    }

    /// Assert didError is called if the server returns an error
    func testWithServerError() throws {
        MockedTasksExecutor.error = MockServerError.serverError("error 500")
        let mockDelegate = MockedPlayerDelegate(testCase: self)
        _ = mockDelegate.expectationError()

        let controller = ApiVideoPlayerController(
            videoOptions: VideoOptions(
                videoId: "vi18RL1kvZlDRdzk7Mas59HT",
                videoType: .vod,
                token: "729d939a-b546-4e39-bd15-4dc8123e5ee3"
            ),
            delegates: [mockDelegate],
            taskExecutor: MockedTasksExecutor.self
        )

        waitForExpectations(timeout: 5, handler: nil)
    }
}

enum MockServerError: Error {
    case serverError(String)
}
