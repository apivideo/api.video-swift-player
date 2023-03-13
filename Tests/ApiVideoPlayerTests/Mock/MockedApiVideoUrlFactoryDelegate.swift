import ApiVideoPlayer
import CoreMedia
import Foundation
import XCTest
class MockedApiVideoUrlFactoryDelegate {
    private var errorExpectation: XCTestExpectation?
    private let testCase: XCTestCase

    init(testCase: XCTestCase) {
        self.testCase = testCase
    }

    func expectationError(_ isInverted: Bool = false) -> XCTestExpectation? {
        self.errorExpectation = self.testCase.expectation(description: "error is called")
        if isInverted {
            self.errorExpectation?.isInverted = true
        }
        return self.errorExpectation
    }
}

// MARK: ApiVideoUrlFactoryDelegate

extension MockedApiVideoUrlFactoryDelegate: ApiVideoUrlFactoryDelegate {
    func didError(_: Error) {
        if self.errorExpectation != nil {
            self.errorExpectation?.fulfill()
        }
        self.errorExpectation = nil
    }
}
