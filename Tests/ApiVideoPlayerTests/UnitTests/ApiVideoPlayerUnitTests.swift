@testable import ApiVideoPlayer
import XCTest

/// Unit tests on PlayerController without connection to api.video
/// The connection is mocked with MockedTasksExecutor
@available(iOS 14.0, *)
class ApiVideoPlayerUnitTests: XCTestCase {

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

    guard let resourceUrl = Bundle.module.url(forResource: "responseSuccess", withExtension: "json") else {
      XCTFail("Error can't find the json file")
      return
    }
    do {
      let data = try Data(contentsOf: resourceUrl, options: .mappedIfSafe)
      MockedTasksExecutor.data = data
    } catch {
      XCTFail("Error can't get data from json")
    }
    _ = ApiVideoPlayerController(
      videoId: "vi18RL1kvZlDRdzk7Mas59HT",
      videoType: .vod,
      events: events,
      taskExecutor: MockedTasksExecutor.self
    )
    waitForExpectations(timeout: 10, handler: nil)
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
    guard let resourceUrl = Bundle.module.url(forResource: "responseError", withExtension: "json") else {
      XCTFail("Error can't find the json file")
      return
    }
    do {
      let data = try Data(contentsOf: resourceUrl, options: .mappedIfSafe)
      MockedTasksExecutor.data = data
    } catch {
      XCTFail("Error can't get data from json")
    }

    _ = ApiVideoPlayerController(
      videoId: "vi18RL1kvZlDRdzk7Mas59HT",
      videoType: .vod,
      events: events,
      taskExecutor: MockedTasksExecutor.self
    )
    waitForExpectations(timeout: 10, handler: nil)
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
      videoId: "vi18RL1kvZlDRdzk7Mas59HT",
      videoType: .vod,
      events: events,
      taskExecutor: MockedTasksExecutor.self
    )
    waitForExpectations(timeout: 10, handler: nil)
  }
}

enum MockServerError: Error {
  case serverError(String)
}
