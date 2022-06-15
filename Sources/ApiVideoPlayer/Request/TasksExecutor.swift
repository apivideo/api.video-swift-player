import Foundation

public class TasksExecutor: TasksExecutorProtocol {
  private let decoder = JSONDecoder()
  public static func execute(
    session: URLSession, request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void
  ) {

    let task = session.dataTask(with: request) { (data, response, error) in
      completion(data,response, error)
    }
    task.resume()
  }
}
