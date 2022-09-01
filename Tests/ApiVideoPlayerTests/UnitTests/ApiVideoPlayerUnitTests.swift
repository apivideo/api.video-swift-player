import ApiVideoPlayer
import XCTest

/// Unit tests on PlayerController without connection to api.video
/// The connection is mocked with MockedTasksExecutor
@available(iOS 14.0, *)
class ApiVideoPlayerUnitTests: XCTestCase {
    /// Assert that didError is not called if the JSON is valid
    func testWithValidPlayerManifestJson() throws {
        // MockedTasksExecutor.data = // TODO read valid Player manifest json from responseSuccess
        // let playerController = ApiVideoPlayerController(..., taskExecutor: MockedTasksExecutor)
    }

    /// Assert didError is called if the JSON is invalid (syntax error or missing values)
    func testWithInvalidPlayerManifestJson() throws {
        // MockedTasksExecutor.data = // TODO invalid Player manifest json
        // let playerController = ApiVideoPlayerController(..., taskExecutor: MockedTasksExecutor)
    }

    /// Assert didError is called if the server returns an error
    func testWithServerError() throws {
        // MockedTasksExecutor.error = // TODO error
        // let playerController = ApiVideoPlayerController(..., taskExecutor: MockedTasksExecutor)
    }
}
