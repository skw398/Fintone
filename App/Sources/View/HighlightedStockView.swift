import UIKit

final class HighlightedStockView: UIView {
    @IBOutlet private var symbolLabel: UILabel!
    @IBOutlet private var plusMinusLabel: UILabel!
    @IBOutlet private var changePercentLabel: UILabel!

    func updateView(stocks: [Stock], period: Period, highlightedIndex: Int? = nil) {
        let symbol: String
        let percentChange: String
        let color: UIColor

        if let index = highlightedIndex {
            let stock = stocks[index]
            symbol = stock.symbol
            percentChange = stock.formattedPercentChange(period)
            color = .byUpOrDown(stock.percentChanges[period])
        } else {
            symbol = "Total"
            percentChange = stocks.formattedPercentChange(period)
            color = .byUpOrDown(stocks.percentChange(period))
        }

        symbolLabel.text = symbol
        plusMinusLabel.text = percentChange.prefix(1).description
        changePercentLabel.text = percentChange.dropFirst().description
        plusMinusLabel.textColor = color
        changePercentLabel.textColor = color
    }

    private func setUp() {
        let view = R.nib.highlightedStockView(withOwner: self)!
        view.frame = bounds
        addSubview(view)

        changePercentLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .black)
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
