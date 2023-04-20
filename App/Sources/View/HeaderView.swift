import UIKit

final class HeaderView: UIView {
    @IBOutlet private var latestOpeningDateLabel: UILabel!
    @IBOutlet private var exchangeRateLabel: UILabel!
    @IBOutlet private var exchangeRateTitleLabel: UILabel!

    func updateView(financialData: FinancialData, period: Period) {
        latestOpeningDateLabel.text = period.label(date: financialData.latestOpeningDate)
        exchangeRateLabel.text = String(format: "%.2f", financialData.exchangeRate)
    }

    private func setUp() {
        let view = R.nib.headerView(withOwner: self)!
        view.frame = bounds
        addSubview(view)

        let preferredLanguagesIsEn = LanguageManager.preferredLanguagesIsEn
        exchangeRateLabel.isHidden = preferredLanguagesIsEn
        exchangeRateTitleLabel.isHidden = preferredLanguagesIsEn
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
