import Foundation

public class RequestsBuilder {
    private func setContentType(request: inout URLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    public func getPlayerData(path: URL) -> URLRequest {
        var request = URLRequest(url: path)
        self.setContentType(request: &request)
        request.httpMethod = "GET"
        return request
    }

    public func getSessionToken(path: String) -> URLRequest {
        let url = URL(string: path)!
        var request = URLRequest(url: url)
        self.setContentType(request: &request)
        request.httpMethod = "GET"
        return request
    }

    public func buildUrlSession() -> URLSession {
        return URLSession(configuration: URLSessionConfiguration.default)
    }
}
