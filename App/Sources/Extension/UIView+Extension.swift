import UIKit

extension UIView {
    func fadeIn(withDuration duration: TimeInterval) {
        alpha = 0.5
        Self.animate(withDuration: duration) { [weak self] in
            self?.alpha = 1
        }
    }
}
