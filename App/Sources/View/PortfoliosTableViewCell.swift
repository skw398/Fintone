import UIKit

final class PortfoliosTableViewCell: UITableViewCell {
    @IBOutlet private var containerView: UIView! {
        didSet {
            containerView.layer.cornerRadius = 8
        }
    }

    @IBOutlet private var portfolioNameLabel: UILabel!
    @IBOutlet private var numberOfStocksLabel: UILabel!

    func setContainerViewBackgroundColor(_ color: UIColor) {
        containerView.backgroundColor = color
    }

    func updateView(name: String, numberOfStocks: Int) {
        portfolioNameLabel.text = name
        numberOfStocksLabel.text = numberOfStocks.description + " " + R.string.localizable.stocks()
        containerView.layer.borderColor = UIColor.clear.cgColor
    }
}
