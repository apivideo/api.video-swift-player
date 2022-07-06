import XCTest
@testable import ApiVideoPlayer

@available(iOS 14.0, *)
final class ApiVideoPlayerTests: XCTestCase {
    func testSuccessTask()throws{
        guard let url = Bundle(for: MockedTasksExecutor.self).url(forResource:"responseSuccess", withExtension: "json"), let returnData = try? Data(contentsOf: url) else {
            return
        }
        let request = RequestsBuilder().getPlayerData(path: "https://cdn.api.video/vod/vi18RL1kvZlDRdzk7Mas59HT/hls/manifest.m3u8")
        let session = RequestsBuilder().buildUrlSession()
        MockedTasksExecutor.execute(session: session, request: request){(data,response, error) in
            XCTAssertEqual(returnData, data)
            XCTAssertNil(response)
            XCTAssertNil(error)
        }
    }
    
    func testErrorTask() throws {
        
        let request = RequestsBuilder().getPlayerData(path: "https://cdn.api.video/vod/vi18RL1kvZlDRdzk7Ma/hls/manifest.m3u8")
        let session = RequestsBuilder().buildUrlSession()
        
        MockedTasksExecutor.executefailed(session: session, request: request) { (data, response, error) in
            XCTAssertNotNil(error)
        }
    }
    
    
}
