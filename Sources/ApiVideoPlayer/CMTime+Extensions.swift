import AVFoundation
import Foundation

extension CMTime {
  var roundedSeconds: TimeInterval {
    return seconds.rounded()
  }

  var hours: Int { return Int(self.roundedSeconds / 3_600) }
  var minute: Int { return Int(self.roundedSeconds.truncatingRemainder(dividingBy: 3_600) / 60) }
  var second: Int { return Int(self.roundedSeconds.truncatingRemainder(dividingBy: 60)) }

  var prettyTime: String {
    return self.hours > 0 ?
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
