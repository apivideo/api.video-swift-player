#if !os(macOS)
import AVFoundation
import Foundation
import UIKit
class SliderView: UIView {
    public weak var delegate: SliderViewDelegate?

    public var duration: CMTime = .init(seconds: 0.0, preferredTimescale: 1_000) {
        didSet {
            self.remainingTime = (self.duration - self.currentTime).prettyTime
            self.controlTimerLabel.text = self.remainingTime
            self.setLiveLabel()
        }
    }

    public var currentTime: CMTime = .init(seconds: 0.0, preferredTimescale: 1_000) {
        didSet {
            self.remainingTime = (self.duration - self.currentTime).prettyTime
            self.controlSlider.value = Float(self.currentTime.roundedSeconds / self.duration.roundedSeconds)
            self.controlTimerLabel.text = self.remainingTime
            self.setLiveLabel()
        }
    }

    private var remainingTime: String = ""

    init(frame: CGRect, _ displayLiveBtn: Bool) {

        super.init(frame: frame)
        self.backgroundColor = UIColor.darkGray.withAlphaComponent(0.25)

        addSubview(self.controlSlider)
        self.controlSlider.addTarget(
            self,
            action: #selector(self.playbackSliderValueChanged),
            for: .valueChanged
        )
        self.controlSlider.tintColor = UIColor.orange.withAlphaComponent(0.7)
        self.controlSlider.thumbTintColor = UIColor.white

        if !displayLiveBtn {
            self.setUpVod()
        } else {
            self.setUpLive()
        }
        self.setUpGeneralConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpVod() {
        // Timer Label
        addSubview(self.controlTimerLabel)
        self.controlTimerLabel.textColor = UIColor.white
        self.setUpVodConstraints()
    }

    private func setLiveLabel() {
        let currentTime = self.currentTime
        let duration = self.duration
        let remainingTime = duration - currentTime

        var timeToLive = remainingTime.prettyTime
        if remainingTime > CMTime(seconds: 0.0, preferredTimescale: 1_000) {
            timeToLive = "-\(timeToLive)"
        } else {
            timeToLive = CMTime(seconds: 0.0, preferredTimescale: 1_000).prettyTime
        }
        if remainingTime >= CMTime(seconds: 3, preferredTimescale: 1_000) {
            self.setLiveButtonTintColor(isLive: false)
        } else {
            self.setLiveButtonTintColor(isLive: true)
        }
        self.controlSlider.value = Float(currentTime.roundedSeconds / duration.roundedSeconds)
        self.controlLiveCurrentTimerLabel.text = currentTime.prettyTime
        self.controlTimeToLiveLabel.text = timeToLive
    }

    private func setUpLive() {
        self.addSubview(self.liveButton)
        self.addSubview(self.controlLiveCurrentTimerLabel)
        self.addSubview(self.controlTimeToLiveLabel)

        self.liveButton.addTarget(self, action: #selector(self.goToLive), for: .touchUpInside)
        self.controlLiveCurrentTimerLabel.text = "00:00"
        self.controlTimeToLiveLabel.text = "00:00"

        self.controlLiveCurrentTimerLabel.font = self.controlLiveCurrentTimerLabel.font.withSize(10)
        self.controlTimeToLiveLabel.font = self.controlTimeToLiveLabel.font.withSize(10)
        self.setUpLiveContraints()
    }

    private func setUpGeneralConstraints() {
        // Slider
        self.controlSlider.translatesAutoresizingMaskIntoConstraints = false
        self.controlSlider.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            .isActive = true
        self.controlSlider.leadingAnchor.constraint(
            equalTo: self.leadingAnchor,
            constant: 10
        ).isActive = true
    }

    private func setUpVodConstraints() {
        // Slider right anchor
        self.controlSlider.rightAnchor.constraint(equalTo: self.controlTimerLabel.leftAnchor, constant: -10)
            .isActive = true

        // Timer Label
        self.controlTimerLabel.translatesAutoresizingMaskIntoConstraints = false
        self.controlTimerLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            .isActive = true
    }

    private func setUpLiveContraints() {
        // Slider right anchor
        self.controlSlider.rightAnchor.constraint(equalTo: self.liveButton.leftAnchor, constant: -10)
            .isActive = true

        self.liveButton.translatesAutoresizingMaskIntoConstraints = false
        self.liveButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            .isActive = true
        self.liveButton.rightAnchor.constraint(
            equalTo: self.rightAnchor,
            constant: -10
        ).isActive = true

        self.liveButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        self.liveButton.heightAnchor.constraint(equalToConstant: 25).isActive = true

        self.controlLiveCurrentTimerLabel.translatesAutoresizingMaskIntoConstraints = false
        self.controlLiveCurrentTimerLabel.topAnchor.constraint(equalTo: self.controlSlider.bottomAnchor)
            .isActive = true
        self.controlLiveCurrentTimerLabel.leadingAnchor.constraint(
            equalTo: self.leadingAnchor,
            constant: 10
        ).isActive = true

        self.controlTimeToLiveLabel.translatesAutoresizingMaskIntoConstraints = false
        self.controlTimeToLiveLabel.centerXAnchor.constraint(equalTo: self.liveButton.centerXAnchor)
            .isActive = true
        self.controlTimeToLiveLabel.topAnchor.constraint(equalTo: self.liveButton.bottomAnchor).isActive = true

    }

    let controlSlider: UISlider = {
        let slider = UISlider()
        return slider
    }()

    let controlTimerLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    //    Timers for live
    let controlLiveCurrentTimerLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    let controlTimeToLiveLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    let liveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = .white
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

        if #available(tvOS 13.0, *) {
            btn.setImage(
                UIImage(named: "live-primary", in: ApiVideoPlayerResources.resourceBundle, compatibleWith: nil),
                for: .normal
            )
        } else {
            // Fallback on earlier versions
        }
        return btn
    }()

    @objc
    func goToLive() {
        self.delegate?.goBackToLive()
        self.setLiveButtonTintColor(isLive: true)
    }

    @objc
    func playbackSliderValueChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                // handle drag began
                self.delegate?.sliderValueChangeDidStart(position: Float64(slider.value))

            case .moved:
                // handle drag moved
                self.delegate?.sliderValueChangeDidMove(position: Float64(slider.value))

            case .ended:
                // handle drag ended
                self.delegate?.sliderValueChangeDidStop(position: Float64(slider.value))

            default:
                break
            }
        }
    }

    private func setLiveButtonTintColor(isLive: Bool) {
        if isLive {
            self.liveButton.tintColor = .red
        } else {
            self.liveButton.tintColor = .white
        }
    }
}

public protocol SliderViewDelegate: AnyObject {
    func sliderValueChangeDidStart(position: Float64)
    func sliderValueChangeDidMove(position: Float64)
    func sliderValueChangeDidStop(position: Float64)
    func goBackToLive()
}
#endif
