@testable import ApiVideoPlayer
import XCTest

/// Unit tests on PlayerController without connection to api.video
/// The connection is mocked with MockedTasksExecutor
@available(iOS 14.0, *)
class ApiVideoPlayerUnitTests: XCTestCase {

  /// Assert that didError is not called if the JSON is valid
  func testWithValidPlayerManifestJson() throws {
    let events = PlayerEvents(
      didPrepare: { () in
        print("didPrepare")
        XCTAssertTrue(true)
      },
      didError: { error in
        print("error \(error)")
        XCTFail("Error should success")
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
    let _ = ApiVideoPlayerController(
      videoId: "vi18RL1kvZlDRdzk7Mas59HT",
      videoType: .vod,
      events: events,
      taskExecutor: MockedTasksExecutor.self
    )
  }

  /// Assert didError is called if the JSON is invalid (syntax error or missing values)
  func testWithInvalidPlayerManifestJson() throws {
    let events = PlayerEvents(
      didPrepare: { () in
        print("didPrepare")
        XCTFail("Should get an error")
      },
      didError: { error in
        print("error toto \(error)")
        XCTAssertTrue(true)
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

    let _ = ApiVideoPlayerController(
      videoId: "vi18RL1kvZlDRdzk7Mas59HT",
      videoType: .vod,
      events: events,
      taskExecutor: MockedTasksExecutor.self
    )
  }

  /// Assert didError is called if the server returns an error
  func testWithServerError() throws {
    MockedTasksExecutor.error = MockServerError.serverError("error 500")
    let events = PlayerEvents(
      didPrepare: { () in
        print("didPrepare")
        XCTFail("Should get an error")
      },
      didError: { error in
        print("error toto \(error)")
        XCTAssertTrue(true)
      }
    )
    let _ = ApiVideoPlayerController(
      videoId: "vi18RL1kvZlDRdzk7Mas59HT",
      videoType: .vod,
      events: events,
      taskExecutor: MockedTasksExecutor.self
    )
  }
}

enum MockServerError: Error {
  case serverError(String)
}
