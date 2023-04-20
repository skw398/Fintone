import UIKit

final class IndexView: UIView {
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var percentChangeLabel: UILabel!
    @IBOutlet private var colorView: UIView!

    func updateView(index: Index, period: Period) {
        nameLabel.text = index.name
        priceLabel.text = index.formattedPrice
        percentChangeLabel.text = index.formattedPercentChange(period)
        percentChangeLabel.textColor = .byUpOrDown(index.percentChanges[period])
        colorView.backgroundColor = .byPercentChange(index.percentChanges[period], period: period)
        colorView.fadeIn(withDuration: 0.3)
    }

    private func setUp() {
        let view = R.nib.indexView(withOwner: self)!
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
