import ApiVideoPlayer
import CoreMedia
import Foundation
import XCTest

class MockedPlayerDelegate {
    private var completedExpectationPrepare: XCTestExpectation?
    private var completedExpectationReady: XCTestExpectation?
    private var completedExpectationPlay: XCTestExpectation?
    private var completedExpectationPause: XCTestExpectation?
    private var completedExpectationMultiplePause: XCTestExpectation?
    private var errorExpectation: XCTestExpectation?
    private var didPauseCalled = false

    private let testCase: XCTestCase

    init(testCase: XCTestCase) {
        self.testCase = testCase
    }

    func expectationPrepare(_ isInverted: Bool = false) -> XCTestExpectation {
        let completedExpectationPrepare = testCase.expectation(description: "Completed Prepare")
        if isInverted {
            completedExpectationPrepare.isInverted = true
        }
        self.completedExpectationPrepare = completedExpectationPrepare
        return completedExpectationPrepare
    }

    func expectationReady(_ isInverted: Bool = false) -> XCTestExpectation {
        let completedExpectationReady = testCase.expectation(description: "Completed Ready")
        if isInverted {
            completedExpectationReady.isInverted = true
        }
        self.completedExpectationReady = completedExpectationReady
        return completedExpectationReady
    }

    func expectationPlay() -> XCTestExpectation {
        let completedExpectationPlay = testCase.expectation(description: "Completed Play")
        self.completedExpectationPlay = completedExpectationPlay
        return completedExpectationPlay
    }

    func expectationPause() -> XCTestExpectation {
        let completedExpectationPause = testCase.expectation(description: "Completed Pause")
        self.completedExpectationPause = completedExpectationPause
        return completedExpectationPause
    }

    func expectationMultiplePause() -> XCTestExpectation {
        let completedExpectationMultiplePause = testCase.expectation(description: "Completed Multiple Pause")
        completedExpectationMultiplePause.isInverted = true
        self.completedExpectationMultiplePause = completedExpectationMultiplePause
        return completedExpectationMultiplePause
    }

    func expectationError(_ isInverted: Bool = false) -> XCTestExpectation {
        let errorExpectation = testCase.expectation(description: "error is called")
        if isInverted {
            errorExpectation.isInverted = true
        }
        self.errorExpectation = errorExpectation
        return errorExpectation
    }
}

// MARK: PlayerDelegate

extension MockedPlayerDelegate: PlayerDelegate {
    func didPrepare() {
        print("test didPrepare")
        completedExpectationPrepare?.fulfill()
        completedExpectationPrepare = nil
    }

    func didReady() {
        print("test didReady")
        completedExpectationReady?.fulfill()
        completedExpectationReady = nil
    }

    func didPause() {
        print("test didPause")
        if !didPauseCalled {
            didPauseCalled = true
            completedExpectationPause?.fulfill()
            completedExpectationPause = nil
        } else {
            completedExpectationMultiplePause?.fulfill()
            completedExpectationMultiplePause = nil
        }
    }

    func didPlay() {
        print("test didPlay")
        completedExpectationPlay?.fulfill()
        completedExpectationPlay = nil
    }

    func didReplay() {}

    func didMute() {}

    func didUnMute() {}

    func didLoop() {}

    func didSetVolume(_: Float) {}

    func didSeek(_: CMTime, _: CMTime) {}

    func didEnd() {}

    func didError(_ error: Error) {
        print("didError: \(error)")
        errorExpectation?.fulfill()
        errorExpectation = nil
    }

    func didVideoSizeChanged(_: CGSize) {}
}

enum MockDelegateError: Error {
    case playerEventDelegateError(String)
}
