import AVFoundation
import Foundation

extension CMTime {
  var roundedSeconds: TimeInterval {
    seconds.rounded()
  }

  var hours: Int { Int(self.roundedSeconds / 3_600) }
  var minute: Int { Int(self.roundedSeconds.truncatingRemainder(dividingBy: 3_600) / 60) }
  var second: Int { Int(self.roundedSeconds.truncatingRemainder(dividingBy: 60)) }

  var prettyTime: String {
    self.hours > 0 ?
      String(
        format: "%d:%02d:%02d",
        self.hours,
        self.minute,
        self.second
      ) :
      String(
        format: "%02d:%02d",
        self.minute,
        self.second
      )
  }
}
