import Foundation

public protocol SliderViewDelegate: AnyObject {
    func sliderValueChangeDidStart(position: Float64)
    func sliderValueChangeDidMove(position: Float64)
    func sliderValueChangeDidStop(position: Float64)
    func addEvents(events: PlayerEvents)
    func goBackToLive()
}
