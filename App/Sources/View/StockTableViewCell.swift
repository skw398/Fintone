import UIKit

final class StockTableViewCell: UITableViewCell {
    @IBOutlet private var logoView: UIImageView!
    @IBOutlet private var symbolLabel: UILabel!
    @IBOutlet private var companyNameLabel: UILabel!
    @IBOutlet private var currentPriceLabel: UILabel!
    @IBOutlet private var marketValueLabel: UILabel! {
        didSet {
            marketValueLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        }
    }

    @IBOutlet private var profitOrLossLabel: UILabel! {
        didSet {
            profitOrLossLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        }
    }

    @IBOutlet private var menuButton: UIButton!
    @IBOutlet private var warningButton: UIButton!
    @IBOutlet private var changePercentLabel: UILabel!
    @IBOutlet private var amountLabel: UILabel!

    private var didTapEditButtonAction: (@MainActor (_ indexPath: IndexPath) -> Void)!
    private var didTapDeleteButtonAction: (@MainActor (_ indexPath: IndexPath) -> Void)!

    func setActions(
        didTapEditButtonAction: @escaping @MainActor (_ indexPath: IndexPath) -> Void,
        didTapDeleteButtonAction: @escaping @MainActor (_ indexPath: IndexPath) -> Void,
        didTapWarningButtonAction: @escaping @MainActor () -> Void
    ) {
        self.didTapEditButtonAction = didTapEditButtonAction
        self.didTapDeleteButtonAction = didTapDeleteButtonAction

        warningButton.addAction(.init(handler: { _ in
            didTapWarningButtonAction()
        }), for: .touchUpInside)
    }

    func updateCell(indexPath: IndexPath, stocks: [Stock], period: Period) {
        let stock = stocks[indexPath.row]
        setMenuButton(indexPath: indexPath)
        updateViewForTradingStatus(isActivelyTrading: stock.isActivelyTrading, indexPath: indexPath)
        logoView.setLogoImage(for: stock)

        symbolLabel.text = stock.symbol
        updateNameLabel(stock: stock)
        amountLabel.text = "× " + stock.formattedAmount
        currentPriceLabel.text = stock.formattedPrice
        changePercentLabel.text = stock.formattedPercentChange(period)
        marketValueLabel.text = stock.formattedMarketValue
        profitOrLossLabel.text = stock.formattedProfitOrLoss(period)

        changePercentLabel.textColor = .byUpOrDown(stock.percentChanges[period])
        profitOrLossLabel.textColor = .byUpOrDown(stock.profitOrLoss(period))

        if frame.width < 375 { amountLabel.removeFromSuperview() } // SE 1sh
    }

    private func setMenuButton(indexPath: IndexPath) {
        let items = UIMenu(options: .displayInline, children: [
            UIAction(
                title: R.string.localizable.changeAmount(),
                image: UIImage(systemName: "square.and.pencil"),
                handler: { [weak self] _ in
                    self?.didTapEditButtonAction(indexPath)
                }
            ),

            UIAction(
                title: R.string.localizable.delete(),
                image: UIImage(systemName: "trash"),
                attributes: .destructive,
                handler: { [weak self] _ in
                    self?.didTapDeleteButtonAction(indexPath)
                }
            ),
        ])
        menuButton.menu = UIMenu(title: "", children: [items])
        menuButton.showsMenuAsPrimaryAction = true
    }

    private func updateNameLabel(stock: Stock) {
        let text = NSMutableAttributedString(string: stock.isETF ? "ETF  " + stock.name : stock.name)
        if stock.isETF {
            text.addAttribute(.foregroundColor, value: UIColor.white, range: NSMakeRange(0, 3))
            text.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .heavy), range: NSMakeRange(0, 3))
        }
        companyNameLabel.attributedText = text
    }

    private func updateViewForTradingStatus(isActivelyTrading: Bool, indexPath: IndexPath) {
        warningButton.isHidden = isActivelyTrading
        amountLabel.isHidden = !isActivelyTrading

        if !isActivelyTrading {
            let action = UIAction(
                title: R.string.localizable.delete(),
                image: UIImage(systemName: "trash"),
                attributes: .destructive,
                handler: { [weak self] _ in
                    self?.didTapDeleteButtonAction(indexPath)
                }
            )
            menuButton.menu = UIMenu(title: "", children: [action])
        }
    }
}
