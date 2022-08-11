@testable import ApiVideoPlayer
import XCTest

@available(iOS 14.0, *)
final class ApiVideoPlayerTests: XCTestCase {
  func testSuccessTask() throws {
    guard let url = Bundle(for: MockedTasksExecutor.self).url(forResource: "responseSuccess", withExtension: "json"),
          let returnData = try? Data(contentsOf: url) else
    {
      return
    }
    guard let path = URL(string: "https://cdn.api.video/vod/vi18RL1kvZlDRdzk7Mas59HT/hls/manifest.m3u8") else {
      return
    }
    let request = RequestsBuilder()
      .getPlayerData(path: path)
    let session = RequestsBuilder().buildUrlSession()
    MockedTasksExecutor.execute(session: session, request: request) { data, error in
      XCTAssertEqual(returnData, data)
      XCTAssertNil(error)
    }
  }

  func testErrorTask() throws {
    guard let path = URL(string: "https://cdn.api.video/vod/vi18RL1kvZlDRdzk7Ma/hls/manifest.m3u8") else {
      return
    }
    let request = RequestsBuilder()
      .getPlayerData(path: path)
    let session = RequestsBuilder().buildUrlSession()

    MockedTasksExecutor.executefailed(session: session, request: request) { _, error in
      XCTAssertNotNil(error)
    }
  }
}
