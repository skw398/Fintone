import UIKit

final class HeaderView: UIView {
    @IBOutlet private var latestOpeningDateLabel: UILabel!
    @IBOutlet private var exchangeRateLabel: UILabel!
    @IBOutlet private var exchangeRateTitleLabel: UILabel!
    @IBOutlet private var selectCurrencyButton: UIButton!
    
    private var selectedCurrency: Currency { AppPreferenceManager.currency }
    
    func updateView(financialData: FinancialData, period: Period) {
        latestOpeningDateLabel.text = period.label(date: financialData.latestOpeningDate)
        exchangeRateTitleLabel.text = AppPreferenceManager.currency.name
        exchangeRateLabel.text = String(format: "%.2f", financialData.exchangeRate)
    }

    private func setUp() {
        let view = R.nib.headerView(withOwner: self)!
        view.frame = bounds
        addSubview(view)
    }
    
    func setActions(didTapSelectCurrencyButtonAction: @escaping @MainActor () -> Void) {
        configureSelectCurrencyButton(action: didTapSelectCurrencyButtonAction)
    }
    
    private func configureSelectCurrencyButton(action: @escaping @MainActor () -> Void) {
        let actions: [UIAction] = Currency.allCases.map { currency in
            .init(
                title: currency.name,
                state: self.selectedCurrency == currency ? .on : .off,
                handler: { [weak self] _ in
                    AppPreferenceManager.currency = currency
                    action()
                    self?.configureSelectCurrencyButton(action: action)
                }
            )
        }
        let items = UIMenu(options: .displayInline, children: actions)
        selectCurrencyButton.menu = UIMenu(title: "", children: [items])
        selectCurrencyButton.showsMenuAsPrimaryAction = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
}
