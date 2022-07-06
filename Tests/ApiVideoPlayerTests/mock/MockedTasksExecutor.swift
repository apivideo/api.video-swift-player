import Foundation
import ApiVideoPlayer

class MockedTasksExecutor: TasksExecutorProtocol {
  static func execute(
    session: URLSession, request: URLRequest, completion: @escaping (Data?,URLResponse?, Error?) -> Void
  ) {
    guard
      let url = Bundle(for: MockedTasksExecutor.self).url(
        forResource: "responseSuccess", withExtension: "json")
    else {
      return
    }
    guard let data = try? Data(contentsOf: url) else {
      return
    }
    completion(data,nil, nil)
  }

  public static func executefailed(
    session: URLSession, request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void
  ) {
      let error = PlayerTestError.executeFailed("400")
      let resp = URLResponse()
    completion(nil,nil, error)
  }
}

public enum PlayerTestError: Error {
  case executeFailed(String)
}


