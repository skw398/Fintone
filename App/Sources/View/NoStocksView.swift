import UIKit

final class NoStocksView: UIView {
    @IBOutlet private var addStockButton: UIButton! {
        didSet {
            addStockButton.setTitle(" " + R.string.localizable.noSymbols(), for: .normal)
            addStockButton.layer.cornerRadius = 8
            addStockButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .black)
        }
    }

    func setActions(didTapAddStockButtonAction: @escaping @MainActor () -> Void) {
        addStockButton.addAction(.init(handler: { _ in
            didTapAddStockButtonAction()
        }), for: .touchUpInside)
    }

    private func setUp() {
        let view = R.nib.noStocksView(withOwner: self)!
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
