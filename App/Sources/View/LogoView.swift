import UIKit

final class LogoView: UIView {
    @IBOutlet private var FMPLinkButton: UIButton!

    private func setUp() {
        let view = R.nib.logoView(withOwner: self)!
        view.frame = bounds
        addSubview(view)

        FMPLinkButton.addAction(.init(handler: { _ in
            UIApplication.shared.open(URL(string: "https://site.financialmodelingprep.com/developer/docs")!)
        }), for: .touchUpInside)
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
