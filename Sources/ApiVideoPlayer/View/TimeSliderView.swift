#if !os(macOS)
import AVFoundation
import Foundation
import UIKit

/*
 * TODO: the slider move when the time labels are updated (bad UX) - warning: text label could be 5 characters long or more
 */
class TimeSliderView: UIStackView {
    public weak var delegate: TimeSliderViewDelegate?

    /// The playback slider
    private let playbackSlider: UISlider = {
        let slider = UISlider()
        slider.sizeToFit()
        return slider
    }()

    /// The remaining time label
    private let remainingTimeLabel: UILabel = {
        let label = UILabel()
        label.text = CMTime.zero.stringRepresentation
        label.tintColor = .white
        label.sizeToFit()
        return label
    }()

    /// The elapsed time label
    private let elapsedTimeLabel: UILabel = {
        let label = UILabel()
        label.text = CMTime.zero.stringRepresentation
        label.tintColor = .white
        label.sizeToFit()
        return label
    }()

    public var duration: CMTime = .zero {
        didSet {
            let nextDuration: CMTime
            if duration.isValid {
                nextDuration = duration
            } else {
                nextDuration = .zero
            }
            playbackSlider.maximumValue = Float(nextDuration.seconds)
            updateTimeLabels()
        }
    }

    public var currentTime: CMTime = .zero {
        didSet {
            let nextCurrentTime: CMTime
            if currentTime.isValid {
                nextCurrentTime = currentTime
            } else {
                nextCurrentTime = .zero
            }
            playbackSlider.value = Float(nextCurrentTime.seconds)
            updateTimeLabels()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.axis = .horizontal
        self.distribution = .fill
        self.alignment = .fill
        self.spacing = 6
        addSubviews()
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {

        addArrangedSubview(elapsedTimeLabel)
        addArrangedSubview(playbackSlider)
        addArrangedSubview(remainingTimeLabel)

        playbackSlider.addTarget(
            self,
            action: #selector(playbackSliderValueChanged),
            for: .valueChanged
        )
        playbackSlider.tintColor = UIColor.orange.withAlphaComponent(0.7)
        playbackSlider.thumbTintColor = UIColor.white

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
        let remainingTimeLabelText: String

        if duration.isValid && currentTime.isValid {
            remainingTimeLabelText = clampedStringRepresentation(duration - currentTime)
        } else {
            remainingTimeLabelText = CMTime.invalidStringRepresentation
        }
        elapsedTimeLabel.text = currentTime.stringRepresentation
        remainingTimeLabel.text = remainingTimeLabelText
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
