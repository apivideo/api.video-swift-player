@testable import ApiVideoPlayer
import CoreMedia
import XCTest
/// Unit tests on PlayerController without connection to api.video
/// The connection is mocked with MockedTasksExecutor
class ApiVideoUrlFactoryUnitTests: XCTestCase {
    private var errorExpectation: XCTestExpectation?
    private var successExpectation: XCTestExpectation?

    func expectationError(_ isInverted: Bool = false) -> XCTestExpectation? {
        self.errorExpectation = self.expectation(description: "error is called")
        if isInverted {
            self.errorExpectation?.isInverted = true
        }
        return self.errorExpectation
    }

    func expectationSuccess(_ isInverted: Bool = false) -> XCTestExpectation? {
        self.successExpectation = self.expectation(description: "success is called")
        if isInverted {
            self.successExpectation?.isInverted = true
        }
        return self.successExpectation
    }

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
        _ = expectationError(true)
        _ = expectationSuccess()

        let urlFactory = ApiVideoUrlFactory(videoOptions: VideoOptions(
            videoId: "vi2H6m1D23s0lGQnYZJyIp7e",
            videoType: .vod,
            token: "729d939a-b546-4e39-bd15-4dc8123e5ee3"
        ), taskExecutor: MockedTasksExecutor.self)
        urlFactory.delegate = self
        urlFactory.getHlsUrl { currentItem in
            print("currentItem : \(currentItem)")
            self.successExpectation?.fulfill()
            self.successExpectation = nil
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    /// Assert that didError is not called if the JSON is valid
    func testWithNilToken() throws {
        generateResource(resource: "responseSuccess")
        _ = expectationError(true)
        _ = expectationSuccess()

        let urlFactory = ApiVideoUrlFactory(videoOptions: VideoOptions(
            videoId: "vi2H6m1D23s0lGQnYZJyIp7e",
            videoType: .vod,
            token: "729d939a-b546-4e39-bd15-4dc8123e5ee3"
        ), taskExecutor: MockedTasksExecutor.self)
        urlFactory.delegate = self
        urlFactory.getHlsUrl { currentItem in
            print("currentItem : \(currentItem)")
            self.successExpectation?.fulfill()
            self.successExpectation = nil
        }
        waitForExpectations(timeout: 15, handler: nil)
    }

    /// Assert didError is called if the JSON is invalid (syntax error or missing values)
    func testWithInvalidSessionRequestResponse() throws {
        generateResource(resource: "responseError")
        _ = expectationError()

        let urlFactory = ApiVideoUrlFactory(videoOptions: VideoOptions(
            videoId: "vi2H6m1D23s0lGQnYZJyIp7e",
            videoType: .vod,
            token: "729d939a-b546-4e39-bd15-4dc8123e5ee3"
        ), taskExecutor: MockedTasksExecutor.self)
        urlFactory.delegate = self
        urlFactory.getHlsUrl { currentItem in
            print("currentItem : \(currentItem)")
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    /// Assert didError is called if the server returns an error
    func testWithServerError() throws {
        MockedTasksExecutor.error = MockServerError.serverError("error 500")
        _ = expectationError()

        let urlFactory = ApiVideoUrlFactory(videoOptions: VideoOptions(
            videoId: "vi2H6m1D23s0lGQnYZJyIp7e",
            videoType: .vod,
            token: "729d939a-b546-4e39-bd15-4dc8123e5ee3"
        ), taskExecutor: MockedTasksExecutor.self)
        urlFactory.delegate = self
        urlFactory.getHlsUrl { currentItem in
            print("currentItem error : \(currentItem)")
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
}

// MARK: ApiVideoUrlFactoryDelegate

extension ApiVideoUrlFactoryUnitTests: ApiVideoUrlFactoryDelegate {
    func didError(_: Error) {
        if self.errorExpectation != nil {
            self.errorExpectation?.fulfill()
        }
        self.errorExpectation = nil
    }
}
