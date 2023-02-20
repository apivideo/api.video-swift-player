import Foundation
class ScheduleTimer {
    public weak var delegate: ScheduleTimerDelegate?
    private var timer: Timer?

    func resetTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }

    @objc
    func activateTimer() {
        guard self.timer == nil else { return }
        self.timer = Timer.scheduledTimer(
            timeInterval: 5,
            target: self,
            selector: #selector(self.activatedTimer),
            userInfo: nil,
            repeats: false
        )
    }

    @objc
    private func activatedTimer() {
        delegate?.didTimerActivated()
    }
}

public protocol ScheduleTimerDelegate: AnyObject {
    func didTimerActivated()
}
