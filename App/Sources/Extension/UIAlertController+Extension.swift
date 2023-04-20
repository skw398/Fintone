import UIKit

extension UIAlertController {
    static func initWithCloseAction(
        title: String, message: String? = nil, closeActionHandler: (() -> Void)? = nil
    ) -> Self {
        let alert: Self = .init(title: title, message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: R.string.localizable.close(), style: .default, handler: { _ in closeActionHandler?() })
        alert.addAction(closeAction)
        return alert
    }
}
