import Foundation
#if !os(macOS)
import UIKit

extension UIButton {
    func setImage(name: String) {
        if #available(iOS 13.0, *) {
            self.setImage(UIImage(systemName: name), for: .normal)
        } else {
            self.setImage(
                UIImage(named: name, in: ApiVideoPlayerResources.resourceBundle, compatibleWith: nil),
                for: .normal
            )
        }
    }
}
#endif
