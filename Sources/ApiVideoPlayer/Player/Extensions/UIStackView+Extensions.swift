#if !os(macOS)
import UIKit

public extension UIStackView {
    var numOfVisibleItems: Int {
        var count = 0
        for view in arrangedSubviews where view.isHidden == false {
            count += 1
        }
        return count
    }

    var hasVisibleItems: Bool {
        numOfVisibleItems > 0
    }
}
#endif
