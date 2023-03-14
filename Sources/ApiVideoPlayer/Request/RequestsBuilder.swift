import Foundation

public enum RequestsBuilder {
    private static func setContentType(request: inout URLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    private static func buildUrlRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        setContentType(request: &request)
        request.httpMethod = "GET"
        return request
    }

    private static func buildUrlSession() -> URLSession {
        URLSession(configuration: URLSessionConfiguration.default)
    }

    public static func getSessionToken(taskExecutor: TasksExecutorProtocol.Type,
                                       url: URL,
                                       completion: @escaping (TokenSession) -> Void,
                                       didError: @escaping (Error) -> Void) {
        let request = buildUrlRequest(url: url)
        let session = buildUrlSession()
        taskExecutor.execute(session: session, request: request) { data, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let token: TokenSession = try decoder.decode(TokenSession.self, from: data)
                    completion(token)
                } catch {
                    didError(error)
                }
            } else {
                if let error = error {
                    didError(error)
                } else {
                    didError(PlayerError.sessionTokenError("Request error, failed to get session token"))
                }
            }
        }
    }
}
