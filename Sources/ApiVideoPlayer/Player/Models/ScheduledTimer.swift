import Foundation

class ScheduledTimer {
    public weak var delegate: ScheduledTimerDelegate?
    private var timer: Timer?
    private let timeInterval: TimeInterval

    init(timeInterval: TimeInterval = 5) {
        self.timeInterval = timeInterval
    }

    /// Launch or re-launch the timer
    func activate() {
        guard timer == nil else {
            return
        }
        timer = Timer.scheduledTimer(
            timeInterval: timeInterval,
            target: self,
            selector: #selector(didFire),
            userInfo: nil,
            repeats: false
        )
    }

    /// Invalidate the timer
    func clear() {
        timer?.invalidate()
        timer = nil
    }

    /// Invalidate the timer, run the action and launch it again
    func reset(action: () -> Void) {
        clear()
        action()
        activate()
    }

    @objc
    private func didFire() {
        delegate?.didTimerFire()
    }
}

public protocol ScheduledTimerDelegate: AnyObject {
    func didTimerFire()
}
