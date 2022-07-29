import ApiVideoPlayer
import Foundation

class MockedTasksExecutor: TasksExecutorProtocol {
    static func execute(
        session _: URLSession, request _: URLRequest, completion: @escaping (Data?, Error?) -> Void
    ) {
        guard
            let url = Bundle(for: MockedTasksExecutor.self).url(
                forResource: "responseSuccess", withExtension: "json"
            )
        else {
            return
        }
        guard let data = try? Data(contentsOf: url) else {
            return
        }
        completion(data, nil)
    }

    public static func executefailed(
        session _: URLSession, request _: URLRequest, completion: @escaping (Data?, Error?) -> Void
    ) {
        let error = PlayerTestError.executeFailed("400")
        completion(nil, error)
    }
}

public enum PlayerTestError: Error {
    case executeFailed(String)
}
