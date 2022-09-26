import ApiVideoPlayer
import Foundation

class MockedTasksExecutor: TasksExecutorProtocol {
    static var data: Data?
    static var error: Error?

    static func execute(session _: URLSession, request _: URLRequest, completion: @escaping (Data?, Error?) -> Void) {
        if let data = data {
            completion(data, nil)
        } else if let error = error {
            completion(nil, error)
        }
    }
}
