import Foundation

public class RequestsBuilder {
    private static func setContentType(request: inout URLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    public static func buildSessionToken(path: URL) -> URLRequest {
        var request = URLRequest(url: path)
        self.setContentType(request: &request)
        request.httpMethod = "GET"
        return request
    }

    public static func buildUrlSession() -> URLSession {
        return URLSession(configuration: URLSessionConfiguration.default)
    }
}
