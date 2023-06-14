import ApiVideoClient
import ApiVideoPlayer
import Foundation
import XCTest

public enum Utils {
    public static func generateResource(resource: String) {
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

    @available(iOS 13.0, *)
    static func getPrivateToken(videoId _: String) async throws -> String {
        // Init ApiVideoClient
        try XCTSkipIf(Parameters.apiKey == "INTEGRATION_TESTS_API_KEY", "Can't get API key")
        ApiVideoClient.apiKey = Parameters.apiKey
        try? ApiVideoClient.setApplicationName(name: "player-integration-tests", version: "0")

        // Get token
        return try await withCheckedThrowingContinuation { continuation in
            VideosAPI.get(videoId: VideoId.privateVideoId) { video, error in
                if let error = error {
                    print("Can't get video: \(error)")
                    continuation.resume(throwing: error)
                    return
                }
                guard let player = video?.assets?.player else {
                    print("Can't get assets")
                    continuation.resume(throwing: PlayerTestError.invalidAssets("Can't get assets"))
                    return
                }

                continuation.resume(returning: player.components(separatedBy: "=")[1])
            }
        }
    }
}

enum PlayerTestError: Error {
    case invalidAssets(String)
}
