import UIKit

final class InputAmountViewController: UIViewController {
    @IBOutlet private var containerStackView: UIStackView!
    @IBOutlet private var symbolLabel: UILabel!
    @IBOutlet private var companyNameLabel: UILabel!
    @IBOutlet private var currentPriceLabel: UILabel!
    @IBOutlet private var marketValueLabel: UILabel!
    @IBOutlet var logoView: UIImageView! {
        didSet {
            logoView.layer.cornerRadius = 8
        }
    }

    @IBOutlet private var amountTextField: UITextField! {
        didSet {
            amountTextField.delegate = self
        }
    }

    @IBOutlet private var stockInfoAndAmountTextFieldContainerStackView: UIStackView! {
        didSet {
            stockInfoAndAmountTextFieldContainerStackView.clipsToBounds = true
            stockInfoAndAmountTextFieldContainerStackView.layer.borderColor = R.color.brighterBackgroundColor()!.cgColor
            stockInfoAndAmountTextFieldContainerStackView.layer.borderWidth = 1
            stockInfoAndAmountTextFieldContainerStackView.layer.cornerRadius = 8
        }
    }

    @IBOutlet private var enterButton: UIButton! {
        didSet {
            enterButton.layer.cornerRadius = 8
            enterButton.setTitle(R.string.localizable.kakutei(), for: .normal)
            enterButton.addAction(.init(handler: { [weak self] _ in
                guard let self,
                      let stringInputedAmount = self.amountTextField.text,
                      let amount = Int(stringInputedAmount),
                      amount > 0
                else { return }
                self.didTapEnterButtonAction(self.stock.symbol, amount)
                self.dismiss(animated: true)
            }), for: .touchUpInside)
        }
    }

    @IBOutlet private var layoutStackViewHeight: NSLayoutConstraint!

    var stock: Stock!
    var portfolio: Portfolio!

    var didTapEnterButtonAction: (@MainActor (_ symbol: String, _ amount: Int) -> Void)!

    func setActions(didTapEnterButtonAction: @escaping @MainActor (_ symbol: String, _ amount: Int) -> Void) {
        self.didTapEnterButtonAction = didTapEnterButtonAction
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        amountTextField.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        configureView()
    }

    private func configureView() {
        symbolLabel.text = stock.symbol
        companyNameLabel.attributedText = attributedCompanyNameWithETFPrefixIfNeeded()
        currentPriceLabel.text = stock.formattedPrice
        logoView.setLogoImage(for: stock)
        if portfolio.orderedSymbols.contains(stock.symbol) {
            amountTextField.text = String(Int(stock.amount))
        }
        enterButton.setEnabled(portfolio.orderedSymbols.contains(stock.symbol))
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
        let point = touches.first!.location(in: containerStackView)
        if !containerStackView.layer.contains(point) {
            dismiss(animated: true)
        }
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            layoutStackViewHeight.constant = keyboardSize.height + 8
        }
    }

    private func attributedCompanyNameWithETFPrefixIfNeeded() -> NSAttributedString {
        let text = NSMutableAttributedString(string: stock.isETF ? "ETF  " + stock.name : stock.name)
        if stock.isETF {
            text.addAttribute(.foregroundColor, value: UIColor.white, range: NSMakeRange(0, 3))
            text.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .heavy), range: NSMakeRange(0, 3))
        }
        return text
    }

    private func validateAndProcessForAmount(_: String?) -> Int? {
        guard let text = amountTextField.text,
              let amount = Int(text),
              amount > 0
        else {
            return nil
        }
        return amount
    }

    private func clearInputAmountTextFieldAndMarketValueLabel() {
        amountTextField.text = ""
        marketValueLabel.text = "$0"
        marketValueLabel.textColor = .lightGray
    }

    private func showExceed10DigitsAlert() {
        let alert = UIAlertController.initWithCloseAction(title: R.string.localizable.exceeding10Digits())
        present(alert, animated: true)
    }

    private func showExceed1BillionAlert() {
        let alert = UIAlertController.initWithCloseAction(title: R.string.localizable.exceeding1Billion())
        present(alert, animated: true)
    }
}

extension InputAmountViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_: UITextField) {
        guard let amount = validateAndProcessForAmount(amountTextField.text) else {
            clearInputAmountTextFieldAndMarketValueLabel()
            enterButton.setEnabled(false)
            return
        }

        stock.amount = amount

        if amount.description.count > 10 {
            amountTextField.text = amount.description.prefix(10).description
            showExceed10DigitsAlert()
        } else if stock.marketValue >= 1_000_000_000 {
            amountTextField.text = amount.description.prefix(amount.description.count - 1).description
            showExceed1BillionAlert()
        } else {
            marketValueLabel.text = stock.formattedMarketValue
            marketValueLabel.textColor = .white
        }

        enterButton.setEnabled(true)
    }
}

private extension UIButton {
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        alpha = enabled ? 1 : 0.5
    }
}
