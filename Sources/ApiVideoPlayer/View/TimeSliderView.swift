#if !os(macOS)
import AVFoundation
import Foundation
import UIKit

/*
 * TODO: the slider move when the time labels are updated (bad UX) - warning: text label could be 5 characters long or more
 * TODO: the slider does not response to user events
 */
class TimeSliderView: UIView {
    public weak var delegate: TimeSliderViewDelegate?

    /// The playback slider
    private let playbackSlider: UISlider = {
        let slider = UISlider()
        return slider
    }()

    /// The remaining time label
    private let remainingTimeLabel: UILabel = {
        let label = UILabel()
        label.text = CMTime.zero.stringRepresentation
        label.tintColor = .white
        return label
    }()

    /// The elapsed time label
    private let elapsedTimeLabel: UILabel = {
        let label = UILabel()
        label.text = CMTime.zero.stringRepresentation
        label.tintColor = .white
        return label
    }()

    public var duration: CMTime = CMTime.zero {
        didSet {
            playbackSlider.maximumValue = Float(duration.seconds)
            updateTimeLabels()
        }
    }

    public var currentTime: CMTime = CMTime.zero {
        didSet {
            playbackSlider.value = Float(currentTime.seconds)
            updateTimeLabels()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        addSubview(playbackSlider)
        addSubview(elapsedTimeLabel)
        addSubview(remainingTimeLabel)

        playbackSlider.addTarget(
                self,
                action: #selector(playbackSliderValueChanged),
                for: .valueChanged
        )
        playbackSlider.tintColor = UIColor.orange.withAlphaComponent(0.7)
        playbackSlider.thumbTintColor = UIColor.white

        addConstraints()
    }

    private func addConstraints() {
        // Slider
        playbackSlider.translatesAutoresizingMaskIntoConstraints = false
        playbackSlider.centerYAnchor.constraint(equalTo: centerYAnchor)
                .isActive = true
        playbackSlider.leftAnchor.constraint(equalTo: elapsedTimeLabel.rightAnchor, constant: 10)
                .isActive = true
        playbackSlider.rightAnchor.constraint(equalTo: remainingTimeLabel.leftAnchor, constant: -10)
                .isActive = true

        // Elapsed time label
        elapsedTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        elapsedTimeLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
                .isActive = true
        elapsedTimeLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10)
                .isActive = true

        // Remaining time label
        remainingTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        remainingTimeLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
                .isActive = true
        remainingTimeLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10)
                .isActive = true
    }

    @objc
    func playbackSliderValueChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                // handle drag began
                delegate?.sliderValueChangedDidStart(position: Float64(slider.value))

            case .moved:
                // handle drag moved
                delegate?.sliderValueChangedDidMove(position: Float64(slider.value))

            case .ended:
                // handle drag ended
                delegate?.sliderValueChangedDidStop(position: Float64(slider.value))

            default:
                break
            }
        }
    }

    private func updateTimeLabels() {
        elapsedTimeLabel.text = clampedStringRepresentation(currentTime)
        remainingTimeLabel.text = clampedStringRepresentation(duration - currentTime)
    }

    private func clampedStringRepresentation(_ time: CMTime) -> String {
        CMTimeClampToRange(time, range: CMTimeRange(start: CMTime.zero, duration: duration)).stringRepresentation
    }
}

public protocol TimeSliderViewDelegate: AnyObject {
    func sliderValueChangedDidStart(position: Float64)
    func sliderValueChangedDidMove(position: Float64)
    func sliderValueChangedDidStop(position: Float64)
}
#endif
