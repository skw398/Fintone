import UIKit

final class PortfolioNameInputAlertController: UIAlertController {
    convenience init(
        title: String,
        portfolio: Portfolio? = nil,
        doneActionHandler: @escaping @MainActor (_ name: String) -> Void
    ) {
        self.init(title: title, message: nil, preferredStyle: .alert)
        let doneAction = UIAlertAction(title: R.string.localizable.kakutei(), style: .default) { [weak self] _ in
            if let text = self?.textFields?.first?.text {
                doneActionHandler(text.trimmingCharacters(in: .whitespaces))
            }
        }
        doneAction.isEnabled = portfolio != nil
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel)
        addTextField { [weak self] textField in
            guard let self else { return }
            textField.text = portfolio?.name
            textField.placeholder = R.string.localizable.portfolioName()
            textField.delegate = self
            textField.returnKeyType = .done
        }
        addAction(doneAction)
        addAction(cancelAction)
    }

    private func validate(_ text: String?) -> Bool {
        guard let text else { return false }
        return !text.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

extension PortfolioNameInputAlertController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        let length = text.count + string.count - range.length
        return length <= 30
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        actions[0].isEnabled = validate(textField.text)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        validate(textField.text)
    }
}
