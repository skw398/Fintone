import UIKit

final class ColorLegendView: UIView {
    @IBOutlet private var thresholdLabel: UILabel!
    @IBOutlet private var colorLegendItems: [UIView]!

    func updateLabel(period: Period) {
        thresholdLabel.text = "±" + Int(period.colorPercentChangeThreshold()).description + "%"
    }

    private func configure() {
        zip(UIColor.legendColors, colorLegendItems).forEach { color, item in
            item.backgroundColor = color
        }
    }

    private func setUp() {
        let view = R.nib.colorLegendView(withOwner: self)!
        view.frame = bounds
        addSubview(view)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
        configure()
    }
}
