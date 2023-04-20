import UIKit

final class TotalView: UIView {
    @IBOutlet private var marketValueLabel: UILabel!
    @IBOutlet private var profitOrLossLabel: UILabel!
    @IBOutlet private var sortButton: UIButton!
    @IBOutlet private var sortTypeLabel: UILabel!
    @IBOutlet private var helpButton: UIButton! {
        didSet {
            updateHelpButton(helpViewIsHidden: AppPreferenceManager.helpViewIsHidden)
        }
    }

    private var selectedSortType: SortType { AppPreferenceManager.sortType }

    func setActions(
        didTapSortButtonAction: @escaping @MainActor () -> Void,
        didTapHelpButtonAction: @escaping @MainActor () -> Void
    ) {
        sortButton.addAction(.init(handler: { _ in
            didTapSortButtonAction()
        }), for: .touchUpInside)

        helpButton.addAction(.init(handler: { [weak self] _ in
            AppPreferenceManager.helpViewIsHidden.toggle()
            self?.updateHelpButton(helpViewIsHidden: AppPreferenceManager.helpViewIsHidden)
            didTapHelpButtonAction()
        }), for: .touchUpInside)
    }

    func updateView(stocks: [Stock], period: Period) {
        marketValueLabel.text = stocks.formattedTotalMarketValue
        profitOrLossLabel.text = stocks.formattedProfitOrLoss(period)
        profitOrLossLabel.textColor = .byUpOrDown(stocks.percentChange(period))
        sortTypeLabel.text = selectedSortType == .customOrder ? "" : selectedSortType.sortTypeName
        sortButton.isHidden = selectedSortType == .customOrder && stocks.count > 1 ? false : true
    }

    private func updateHelpButton(helpViewIsHidden: Bool) {
        let imageSystemName = helpViewIsHidden ? "questionmark.circle.fill" : "chevron.up.circle.fill"
        helpButton.setImage(.init(systemName: imageSystemName), for: .normal)
    }

    private func setUp() {
        let view = R.nib.totalView(withOwner: self)!
        view.frame = bounds
        addSubview(view)
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
