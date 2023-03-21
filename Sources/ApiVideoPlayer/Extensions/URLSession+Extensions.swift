import Foundation

extension URLSession {
    enum HTTPError: Error {
        case transportError(Error)
        case serverSideError(Int)
    }

    enum UrlError: Error {
        case urlResponseError(String)
    }

    typealias DataTaskResult = Result<(HTTPURLResponse, Data), Error>

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (DataTaskResult) -> Void
    ) -> URLSessionDataTask {
        self.dataTask(with: request) { data, response, error in
            if let error = error {
                completionHandler(Result.failure(HTTPError.transportError(error)))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                completionHandler(.failure(UrlError.urlResponseError("Could not cast response to HTTPURLResponse")))
                return
            }
            let status = response.statusCode
            guard (200...299).contains(status) else {
                completionHandler(Result.failure(HTTPError.serverSideError(status)))
                return
            }
            guard let myData = data else {
                return
            }
            completionHandler(Result.success((response, myData)))
        }
    }
}