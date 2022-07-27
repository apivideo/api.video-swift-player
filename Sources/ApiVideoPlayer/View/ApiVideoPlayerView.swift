#if !os(macOS)
    import AVKit
    import UIKit

    @available(tvOS 10.0, *)
    @available(iOS 14.0, *)
    public class ApiVideoPlayerView: UIView {
        private let playerLayer = AVPlayerLayer()
        private let videoPlayerView = UIView()
        private var vodControlsView: VodControlsView?
        private var playerController: PlayerController!
        private var userEvents: PlayerEvents?
        private var isFirstPlay = true
        private var isHidenControls: Bool
        public var viewController: UIViewController? {
            didSet {
                vodControlsView?.viewController = viewController
            }
        }

        /// Init method for PlayerView.
        /// - Parameters:
        ///   - frame: frame of theplayer view.
        ///   - videoId: Need videoid to display the video.
        ///   - videoType: VideoType object to display vod or live controls.
        ///   - events: Callback to get all the player events.
        public init(frame: CGRect, videoId: String, hideControls: Bool = false, events: PlayerEvents? = nil) throws {
            userEvents = events
            isHidenControls = hideControls
            super.init(frame: frame)
            do {
                playerController = try PlayerController(videoId: videoId, events: events, view: self, playerLayer: playerLayer)
                if !hideControls {
                    vodControlsView = VodControlsView(frame: .zero, parentView: self, playerController: playerController!)
                }
                setupView()

            } catch {
                return
            }
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupView() {
            if traitCollection.userInterfaceStyle == .dark {
                backgroundColor = .lightGray
            } else {
                backgroundColor = .black
            }
        }

        override public func layoutSubviews() {
            super.layoutSubviews()
            playerLayer.frame = bounds
            vodControlsView?.frame = bounds
        }

        /// Get information if the video is playing.
        /// - Returns: Boolean.
        public func isPlaying() -> Bool {
            return playerController.isPlaying()
        }

        /// Play the video.
        public func play() {
            playerController.play()
        }

        /// Replay the video.
        public func replay() {
            playerController.replay()
        }

        /// Pause the video.
        public func pause() {
            playerController.pause()
        }

        /// Getter and Setter to mute or unmute video player.
        public var isMuted: Bool {
            get { return playerController.isMuted }
            set(newValue) { playerController.isMuted = newValue }
        }

        /// Getter and Setter for player events callback.
        /// Use it if you want to get netified on player events.
        public var events: PlayerEvents? {
            get { return userEvents }
            set(newValue) {
                if let events = userEvents {
                    playerController.removeEvents(events: events)
                }
                if let events = events {
                    playerController.addEvents(events: events)
                }
                userEvents = newValue
            }
        }

        /// Hide all the controls of the player.
        /// By default the controls are on. They will be hide in case of inactivity, and display again on user interaction.
        public func hideControls() {
            vodControlsView?.isHidden = true
        }

        /// Show all the controls of the player.
        /// By default the controls are on. They will be hide in case of inactivity, and display again on user interaction.
        public func showControls() {
            vodControlsView?.isHidden = false
        }

        /// Hide the selected subtitle.
        public func hideSubtitle() {
            playerController.hideSubtitle()
        }

        /// Show the selected subtitles.
        /// - Parameter language: use code language as String (example: "en" for english).
        public var currentSubtitle: Locale {
            get { return Locale(identifier: playerController.currentSubtitle.language) }
            set(newSubtitle) {
                playerController.currentSubtitle = SubtitleLanguage(language: newSubtitle.identifier, code: newSubtitle.languageCode)
            }
        }

        /// Go forward or backward in the video.
        /// - Parameter time: time in seconds, (use minus to go backward).
        public func seek(time: Double) {
            playerController.seek(time: time)
        }

        /// Go forward or backward in the video to a specific time.
        /// - Parameter to: go to a specific time (in second).
        public func seek(to: Double) {
            playerController.seek(to: to)
        }

        /// The video player volume is connected to the device audio volume.
        /// - Parameter volume: Float between 0 to 1.
        public var volume: Float {
            get {
                playerController.volume
            }
            set(newValue) {
                playerController.volume = newValue
            }
        }

        /// Get the duration of the video.
        public var duration: CMTime {
            playerController.duration
        }

        /// Get the current time of the video playing.
        public var currentTime: CMTime {
            playerController.currentTime
        }

        /// Put the video in full screen.
        /// To be able tu use full screen viewController must be set before.
        public func goToFullScreen() {
            guard let vc = viewController else {
                return
            }
            playerController.goToFullScreen(viewController: vc)
        }

        /// Getter and Setter to loop the video
        public var isLoop: Bool {
            get {
                playerController.isLoop
            }
            set(newValue) {
                playerController.isLoop = newValue
            }
        }

        deinit {
            if let events = self.userEvents {
                playerController.removeEvents(events: events)
            }
        }
    }

#else
    import Cocoa
    public class ApiVideoPlayerView: NSView {
        override public init(frame: NSRect) {
            super.init(frame: frame)
        }

        public required init?(coder: NSCoder) {
            super.init(coder: coder)
            layer?.backgroundColor = NSColor.red.cgColor
        }
    }
#endif
