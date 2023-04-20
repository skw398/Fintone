import UIKit

final class HelpView: UIView {
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var percentChangeLabel: UILabel!
    @IBOutlet private var marketValueLabel: UILabel!
    @IBOutlet private var profitOrLossLabel: UILabel!

    private func setUp() {
        let view = R.nib.helpView(withOwner: self)!
        view.frame = bounds
        addSubview(view)

        priceLabel.text = R.string.localizable.price()
        percentChangeLabel.text = R.string.localizable.percentChange()
        marketValueLabel.text = R.string.localizable.marketValue()
        profitOrLossLabel.text = R.string.localizable.profitOrLoss()
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
