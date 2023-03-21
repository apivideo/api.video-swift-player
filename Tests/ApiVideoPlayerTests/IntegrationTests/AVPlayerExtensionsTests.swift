@testable import ApiVideoPlayer
import AVFoundation
import Foundation
import XCTest

/// Integration tests for AVPlayer extension
final class AVPlayerExtensions: XCTestCase {
    func testValidHLSVideoIdPlay() throws {
        let observer = AVPlayerReadyObserverImpl(testCase: self)
        _ = observer.readyExpectation

        let avPlayer = AVPlayer(playerItem: nil)
        avPlayer.replaceCurrentItem(withHls: VideoOptions(videoId: VideoId.validVideoId, videoType: .vod))
        avPlayer.currentItem?.addObserver(observer, forKeyPath: "status", options: .new, context: nil)
        avPlayer.play()

        waitForExpectations(timeout: 10, handler: nil)
        avPlayer.currentItem?.removeObserver(observer, forKeyPath: "status")
    }

    func testValidMP4VideoIdPlay() throws {
        let observer = AVPlayerReadyObserverImpl(testCase: self)
        _ = observer.readyExpectation

        let avPlayer = AVPlayer(playerItem: nil)
        avPlayer.replaceCurrentItem(withMp4: VideoOptions(videoId: VideoId.validVideoId, videoType: .vod))
        avPlayer.currentItem?.addObserver(observer, forKeyPath: "status", options: .new, context: nil)
        avPlayer.play()

        waitForExpectations(timeout: 10, handler: nil)
        avPlayer.currentItem?.removeObserver(observer, forKeyPath: "status")
    }
}

private class AVPlayerReadyObserverImpl: NSObject {
    let readyExpectation: XCTestExpectation

    init(testCase: XCTestCase) {
        readyExpectation = testCase.expectation(description: "Expecting ready to play")
    }

    override public func observeValue(
        forKeyPath keyPath: String?,
        of _: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context _: UnsafeMutableRawPointer?
    ) {
        if keyPath == "status" {
            guard let status = change?[.newKey] as? Int else {
                return
            }
            if status == AVPlayerItem.Status.readyToPlay.rawValue {
                readyExpectation.fulfill()
            }
        }
    }
}
