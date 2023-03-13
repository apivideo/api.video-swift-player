@testable import ApiVideoPlayer
import CoreMedia
import XCTest
/// Unit tests on PlayerController without connection to api.video
/// The connection is mocked with MockedTasksExecutor
class ApiVideoPlayerItemFactoryUnitTests: XCTestCase {
    func generateResource(resource: String) {
        guard let resourceUrl = Bundle.module.url(forResource: resource, withExtension: "json") else {
            XCTFail("Error can't find the json file")
            return
        }
        do {
            let data = try Data(contentsOf: resourceUrl, options: .mappedIfSafe)
            MockedTasksExecutor.data = data
        } catch {
            XCTFail("Error can't get data from json")
        }
    }

    /// Assert that didError is not called if the JSON is valid
    func testWithValidSessionRequest() throws {
        generateResource(resource: "responseSuccess")
        let mockDelegate = MockedApiVideoPlayerItemFactoryDelegate(testCase: self)
        _ = mockDelegate.expectationError(true)

        let playerItemFactory = ApiVideoPlayerItemFactory(videoOptions: VideoOptions(
            videoId: "vi2H6m1D23s0lGQnYZJyIp7e",
            videoType: .vod,
            token: "729d939a-b546-4e39-bd15-4dc8123e5ee3"
        ), taskExecutor: MockedTasksExecutor.self)
        playerItemFactory.delegate = mockDelegate
        playerItemFactory.getHlsPlayerItem { currentItem in
            print("je suis le currentItem : \(currentItem)")
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    /// Assert that didError is not called if the JSON is valid
    func testWithNilToken() throws {
        generateResource(resource: "responseSuccess")
        let mockDelegate = MockedApiVideoPlayerItemFactoryDelegate(testCase: self)
        _ = mockDelegate.expectationError(true)

        let playerItemFactory = ApiVideoPlayerItemFactory(videoOptions: VideoOptions(
            videoId: "vi2H6m1D23s0lGQnYZJyIp7e",
            videoType: .vod,
            token: "729d939a-b546-4e39-bd15-4dc8123e5ee3"
        ), taskExecutor: MockedTasksExecutor.self)
        playerItemFactory.delegate = mockDelegate
        playerItemFactory.getHlsPlayerItem { currentItem in
            print("je suis le currentItem : \(currentItem)")
        }
        waitForExpectations(timeout: 15, handler: nil)
    }

    /// Assert didError is called if the JSON is invalid (syntax error or missing values)
    func testWithInvalidSessionRequestResponse() throws {
        generateResource(resource: "responseError")
        let mockDelegate = MockedApiVideoPlayerItemFactoryDelegate(testCase: self)
        _ = mockDelegate.expectationError()

        let playerItemFactory = ApiVideoPlayerItemFactory(videoOptions: VideoOptions(
            videoId: "vi2H6m1D23s0lGQnYZJyIp7e",
            videoType: .vod,
            token: "729d939a-b546-4e39-bd15-4dc8123e5ee3"
        ), taskExecutor: MockedTasksExecutor.self)
        playerItemFactory.delegate = mockDelegate
        playerItemFactory.getHlsPlayerItem { currentItem in
            print("je suis le currentItem : \(currentItem)")
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    /// Assert didError is called if the server returns an error
    func testWithServerError() throws {
        MockedTasksExecutor.error = MockServerError.serverError("error 500")
        let mockDelegate = MockedApiVideoPlayerItemFactoryDelegate(testCase: self)
        _ = mockDelegate.expectationError()

        let playerItemFactory = ApiVideoPlayerItemFactory(videoOptions: VideoOptions(
            videoId: "vi2H6m1D23s0lGQnYZJyIp7e",
            videoType: .vod,
            token: "729d939a-b546-4e39-bd15-4dc8123e5ee3"
        ), taskExecutor: MockedTasksExecutor.self)
        playerItemFactory.delegate = mockDelegate
        playerItemFactory.getHlsPlayerItem { currentItem in
            print("je suis le currentItem : \(currentItem)")
        }
        waitForExpectations(timeout: 15, handler: nil)
    }
}
