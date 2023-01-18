import Foundation
class SharedTimer {
    static let shared = SharedTimer()

    // TODO: utiliser les events au lieu de la completion
    public var didTimerActivated: (() -> Void)?

    private var timer: Timer?

    private init(didTimerActivated: (() -> Void)? = nil) {
        self.didTimerActivated = didTimerActivated
    }

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
    func activatedTimer() {
        self.didTimerActivated?()
    }

}
