import UIKit

final class StockSearchViewController: UIViewController {
    @IBOutlet private var searchTextField: UITextField!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var searchTextFieldBottomAnchor: NSLayoutConstraint!

    private let stockSearchUseCase = StockSearchUseCase(apiService: ServiceDependencies.apiService)

    var existingSymbols: [String] = []

    private var didFindStockAction: (@MainActor (_ stock: Stock) -> Void)!

    func setAction(didFindStockAction: @escaping @MainActor (_ stock: Stock) -> Void) {
        self.didFindStockAction = didFindStockAction
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let nav = presentingViewController as? UINavigationController {
            nav.view.alpha = 0.3
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let nav = presentingViewController as? UINavigationController {
            nav.view.alpha = 1.0
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let point = touches.first!.location(in: searchTextField)
        if !searchTextField.layer.contains(point) {
            dismiss(animated: true)
        }
    }

    private func searchStock(for symbol: String) {
        let indicatorView = IndicatorView()
        Task {
            indicatorView.start()
            do {
                let stock = try await stockSearchUseCase.execute(with: symbol)
                guard let stock else {
                    indicatorView.stop()
                    showSymbolNotFoundAlert()
                    return
                }
                dismiss(animated: false)
                didFindStockAction(stock)
            } catch {
                var errorDescription = R.string.localizable.unexpectedErrorOccurred()
                if let error = error as? APIServiceError {
                    errorDescription = error.localizedDescription
                }
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                showForFailedToLoadDataAlert(title: errorDescription)
            }
            indicatorView.stop()
        }
    }

    private func validateAndProcessForSearch(_ text: String?) -> String? {
        guard let text = text?
            .trimmingCharacters(in: .whitespaces)
            .uppercased()
            .applyingTransform(.fullwidthToHalfwidth, reverse: false),
            !text.isEmpty
        else {
            return nil
        }
        return text
    }

    private func showAlreadyExitingSymbolAlert() {
        let alert = UIAlertController.initWithCloseAction(title: R.string.localizable.alreadyAddedStock())
        present(alert, animated: true)
    }

    private func showSymbolNotFoundAlert() {
        let alert = UIAlertController.initWithCloseAction(title: R.string.localizable.tickerSymbolNotFound())
        present(alert, animated: true)
    }

    private func showForFailedToLoadDataAlert(title: String) {
        let alert = UIAlertController.initWithCloseAction(title: title)
        present(alert, animated: true)
    }
}

extension StockSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let symbol = validateAndProcessForSearch(textField.text) else { return false }
        if existingSymbols.contains(symbol) {
            showAlreadyExitingSymbolAlert()
            return false
        }
        searchStock(for: symbol)
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        let length = text.count + string.count - range.length
        return length <= 10
    }
}
