import Foundation

/// The default implementation of ``TasksExecutorProtocol`` that uses ``URLSession``.
public class TasksExecutor: TasksExecutorProtocol {
    public static func execute(
        session: URLSession, request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void
    ) {
        let task = session.dataTask(with: request) { result in
            switch result {
            case let .success((_, data)):
                completion(.success(data))

            case let .failure(error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
