import Foundation

public class RequestsBuilder {
  private func setContentType(request: inout URLRequest) {
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
  }

  public func getPlayerData(path: String) -> URLRequest {
    var request = URLRequest(url: URL(string: path)!)
    self.setContentType(request: &request)
    request.httpMethod = "GET"
    return request
  }

  public func buildUrlSession() -> URLSession {
    return URLSession(configuration: URLSessionConfiguration.default)
  }
}
