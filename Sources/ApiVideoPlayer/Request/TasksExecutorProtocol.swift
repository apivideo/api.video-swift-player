import Foundation

/// A protocol that defines the tasks executor for the requests.
/// It is for internal use only.
/// This protocol is used to mock the requests in the tests.
public protocol TasksExecutorProtocol {
    static func execute(
        session: URLSession, request: URLRequest, completion: @escaping (Data?, Error?) -> Void
    )
}
