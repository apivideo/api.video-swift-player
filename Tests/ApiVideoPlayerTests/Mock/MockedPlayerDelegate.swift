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

    func expectationPrepare(_ isInverted: Bool = false) -> XCTestExpectation? {
        self.completedExpectationPrepare = self.testCase.expectation(description: "Completed Prepare")
        if isInverted {
            self.completedExpectationPrepare?.isInverted = true
        }
        return self.completedExpectationPrepare
    }

    func expectationReady(_ isInverted: Bool = false) -> XCTestExpectation? {
        self.completedExpectationReady = self.testCase.expectation(description: "Completed Ready")
        if isInverted {
            self.completedExpectationReady?.isInverted = true
        }
        return self.completedExpectationReady
    }

    func expectationPlay() -> XCTestExpectation? {
        self.completedExpectationPlay = self.testCase.expectation(description: "Completed Play")
        return self.completedExpectationPlay
    }

    func expectationPause() -> XCTestExpectation? {
        self.completedExpectationPause = self.testCase.expectation(description: "Completed Pause")
        return self.completedExpectationPause
    }

    func expectationMultiplePause() -> XCTestExpectation? {
        self.completedExpectationMultiplePause = self.testCase.expectation(description: "Completed Multiple Pause")
        self.completedExpectationMultiplePause?.isInverted = true
        return self.completedExpectationMultiplePause
    }

    func expectationError(_ isInverted: Bool = false) -> XCTestExpectation? {
        self.errorExpectation = self.testCase.expectation(description: "error is called")
        if isInverted {
            self.errorExpectation?.isInverted = true
        }
        return self.errorExpectation
    }
}

// MARK: PlayerDelegate

extension MockedPlayerDelegate: PlayerDelegate {
    func didPrepare() {
        print("test didPrepare")
        if self.completedExpectationPrepare != nil {
            self.completedExpectationPrepare?.fulfill()
        }
        self.completedExpectationPrepare = nil
    }

    func didReady() {
        print("test didReady")
        if self.completedExpectationReady != nil {
            self.completedExpectationReady?.fulfill()
        }
        self.completedExpectationReady = nil
    }

    func didPause() {
        print("test didPause")
        if !self.didPauseCalled {
            self.didPauseCalled = true
            if self.completedExpectationPause != nil {
                self.completedExpectationPause?.fulfill()
            }
            self.completedExpectationPause = nil

        } else {
            if self.completedExpectationMultiplePause != nil {
                self.completedExpectationMultiplePause?.fulfill()
            }
            self.completedExpectationMultiplePause = nil
        }
    }

    func didPlay() {
        print("test didPlay")
        if self.completedExpectationPlay != nil {
            self.completedExpectationPlay?.fulfill()
        }
        self.completedExpectationPlay = nil
    }

    func didReplay() {}

    func didMute() {}

    func didUnMute() {}

    func didLoop() {}

    func didSetVolume(_: Float) {}

    func didSeek(_: CMTime, _: CMTime) {}

    func didEnd() {}

    func didError(_: Error) {
        print("test didError")
        if self.errorExpectation != nil {
            self.errorExpectation?.fulfill()
        }
        self.errorExpectation = nil
    }

    func didVideoSizeChanged(_: CGSize) {}
}

enum MockDelegateError: Error {
    case playerEventDelegateError(String)
}
