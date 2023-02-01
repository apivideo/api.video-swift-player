@testable import ApiVideoPlayer
import XCTest

/// Unit tests on PlayerController without connection to api.video
/// The connection is mocked with MockedTasksExecutor
class ApiVideoPlayerUnitTests: XCTestCase {

    func generateRessource(ressource: String) {
        guard let resourceUrl = Bundle.module.url(forResource: ressource, withExtension: "json") else {
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
    func testWithValidPlayerManifestJson() throws {
        let prepareExpectation = self.expectation(description: "didPrepare is called")
        let errorExpectation = self.expectation(description: "didError is called")
        errorExpectation.isInverted = true
        let events = PlayerEvents(
            didPrepare: { () in
                print("didPrepare")
                prepareExpectation.fulfill()
            },
            didError: { error in
                print("error\(error)")
                errorExpectation.fulfill()
            }
        )
        self.generateRessource(ressource: "responseSuccess")

        _ = ApiVideoPlayerController(
            videoOptions: VideoOptions(videoId: "vi18RL1kvZlDRdzk7Mas59HT"),
            events: events,
            playerControllerEvent: nil,
            taskExecutor: MockedTasksExecutor.self
        )
        waitForExpectations(timeout: 5, handler: nil)
    }

    /// Assert didError is called if the JSON is invalid (syntax error or missing values)
    func testWithInvalidPlayerManifestJson() throws {
        let prepareExpectation = self.expectation(description: "didPrepare is called")
        prepareExpectation.isInverted = true
        let errorExpectation = self.expectation(description: "didError is called")
        let events = PlayerEvents(
            didPrepare: { () in
                print("didPrepare")
                prepareExpectation.fulfill()
            },
            didError: { error in
                print("error \(error)")
                errorExpectation.fulfill()
            }
        )
        self.generateRessource(ressource: "responseError")

        _ = ApiVideoPlayerController(
            videoOptions: VideoOptions(videoId: "vi18RL1kvZlDRdzk7Mas59HT"),
            events: events,
            playerControllerEvent: nil,
            taskExecutor: MockedTasksExecutor.self
        )
        waitForExpectations(timeout: 5, handler: nil)
    }

    /// Assert didError is called if the server returns an error
    func testWithServerError() throws {
        let prepareExpectation = self.expectation(description: "didPrepare is called")
        prepareExpectation.isInverted = true
        let errorExpectation = self.expectation(description: "didError is called")
        MockedTasksExecutor.error = MockServerError.serverError("error 500")
        let events = PlayerEvents(
            didPrepare: { () in
                print("didPrepare")
                prepareExpectation.fulfill()
            },
            didError: { error in
                print("error \(error)")
                errorExpectation.fulfill()
            }
        )
        _ = ApiVideoPlayerController(
            videoOptions: VideoOptions(videoId: "vi18RL1kvZlDRdzk7Mas59HT"),
            events: events,
            playerControllerEvent: nil,
            taskExecutor: MockedTasksExecutor.self
        )
        waitForExpectations(timeout: 5, handler: nil)
    }
}

enum MockServerError: Error {
    case serverError(String)
}
