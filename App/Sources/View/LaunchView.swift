import UIKit

final class LaunchView: UIView {
    @IBOutlet private var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.text = R.string.localizable.failedToFetchData()
        }
    }

    @IBOutlet private var logoView: LogoView!
    @IBOutlet private var retryButton: UIButton! {
        didSet {
            retryButton.setTitle(R.string.localizable.reload(), for: .normal)
            retryButton.layer.cornerRadius = 8
            retryButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .black)
        }
    }

    @IBOutlet private var indicator: UIActivityIndicatorView!

    func setActions(didTapRetryButtonAction: @escaping @MainActor () -> Void) {
        retryButton.addAction(.init(handler: { [weak self] _ in
            self?.isLoading = true
            didTapRetryButtonAction()
        }), for: .touchUpInside)
    }

    private var isLoading = true {
        didSet {
            descriptionLabel.isHidden = isLoading
            retryButton.isHidden = isLoading
            indicator.isHidden = !isLoading
        }
    }

    func failedToLoad(title: String) {
        descriptionLabel.text = title
        isLoading = false
    }

    func show() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first
        {
            frame = window.bounds
            window.addSubview(self)
        }
    }

    func hide() {
        removeFromSuperview()
    }

    private func setUp() {
        let view = R.nib.launchView(withOwner: self)!
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
