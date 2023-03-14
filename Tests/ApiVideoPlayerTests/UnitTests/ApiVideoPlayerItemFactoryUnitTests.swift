@testable import ApiVideoPlayer
import CoreMedia
import XCTest
/// Unit tests on PlayerController without connection to api.video
/// The connection is mocked with MockedTasksExecutor
class ApiVideoPlayerItemFactoryUnitTests: XCTestCase {
    private var errorExpectation: XCTestExpectation?
    private var successExpectation: XCTestExpectation?

    func expectationError(_ isInverted: Bool = false) -> XCTestExpectation {
        let errorExpectation = self.expectation(description: "error is called")
        if isInverted {
            errorExpectation.isInverted = true
        }
        self.errorExpectation = errorExpectation
        return errorExpectation
    }

    func expectationSuccess(_ isInverted: Bool = false) -> XCTestExpectation {
        let successExpectation = self.expectation(description: "success is called")
        if isInverted {
            successExpectation.isInverted = true
        }
        self.successExpectation = successExpectation
        return successExpectation
    }

    /// Assert that didError is not called if the JSON is valid
    func testWithValidSessionRequest() throws {
        Utils.generateResource(resource: "responseSuccess")
        _ = expectationError(true)
        _ = expectationSuccess()

        let playerItemFactory = ApiVideoPlayerItemFactory(videoOptions: VideoOptions(
            videoId: "vi2H6m1D23s0lGQnYZJyIp7e",
            videoType: .vod,
            token: "729d939a-b546-4e39-bd15-4dc8123e5ee3"
        ), taskExecutor: MockedTasksExecutor.self)
        playerItemFactory.delegate = self
        playerItemFactory.getHlsPlayerItem { currentItem in
            print("currentItem : \(currentItem)")
            self.successExpectation?.fulfill()
            self.successExpectation = nil
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    /// Assert that didError is not called if the JSON is valid
    func testWithNilToken() throws {
        Utils.generateResource(resource: "responseSuccess")
        _ = expectationError(true)
        _ = expectationSuccess()

        let playerItemFactory = ApiVideoPlayerItemFactory(videoOptions: VideoOptions(
            videoId: "vi2H6m1D23s0lGQnYZJyIp7e",
            videoType: .vod,
            token: "729d939a-b546-4e39-bd15-4dc8123e5ee3"
        ), taskExecutor: MockedTasksExecutor.self)
        playerItemFactory.delegate = self
        playerItemFactory.getHlsPlayerItem { currentItem in
            print("currentItem : \(currentItem)")
            self.successExpectation?.fulfill()
            self.successExpectation = nil
        }
        waitForExpectations(timeout: 15, handler: nil)
    }

    /// Assert didError is called if the JSON is invalid (syntax error or missing values)
    func testWithInvalidSessionRequestResponse() throws {
        Utils.generateResource(resource: "responseError")
        _ = expectationError()
        let playerItemFactory = ApiVideoPlayerItemFactory(videoOptions: VideoOptions(
            videoId: "vi2H6m1D23s0lGQnYZJyIp7e",
            videoType: .vod,
            token: "729d939a-b546-4e39-bd15-4dc8123e5ee3"
        ), taskExecutor: MockedTasksExecutor.self)
        playerItemFactory.delegate = self
        playerItemFactory.getHlsPlayerItem { _ in }
        waitForExpectations(timeout: 5, handler: nil)
    }

    /// Assert didError is called if the server returns an error
    func testWithServerError() throws {
        MockedTasksExecutor.error = MockServerError.serverError("error 500")
        _ = expectationError()
        let playerItemFactory = ApiVideoPlayerItemFactory(videoOptions: VideoOptions(
            videoId: "vi2H6m1D23s0lGQnYZJyIp7e",
            videoType: .vod,
            token: "729d939a-b546-4e39-bd15-4dc8123e5ee3"
        ), taskExecutor: MockedTasksExecutor.self)
        playerItemFactory.delegate = self
        playerItemFactory.getHlsPlayerItem { _ in }
        waitForExpectations(timeout: 15, handler: nil)
    }
}

// MARK: ApiVideoPlayerItemFactoryDelegate

extension ApiVideoPlayerItemFactoryUnitTests: ApiVideoPlayerItemFactoryDelegate {
    func didError(_: Error) {
        self.errorExpectation?.fulfill()
        self.errorExpectation = nil
    }
}
