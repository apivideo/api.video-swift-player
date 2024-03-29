import ApiVideoPlayer
import Foundation

class MockedTasksExecutor: TasksExecutorProtocol {
    private static var _data: Data?
    private static var _error: Error?

    static var data: Data? {
        didSet {
            _data = data
            _error = nil
        }
    }

    static var error: Error? {
        didSet {
            _data = nil
            _error = error
        }
    }

    static func execute(
        session _: URLSession,
        request _: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        if let data = _data {
            completion(.success(data))
        } else if let error = _error {
            completion(.failure(error))
        }
    }
}
