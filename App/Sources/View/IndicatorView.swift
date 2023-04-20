import UIKit

final class IndicatorView: UIView {
    private let indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .large)
        indicatorView.color = .white
        indicatorView.startAnimating()
        return indicatorView
    }()

    private let containerView: UIView = {
        let view = UIView(frame: .init(origin: .zero, size: .init(width: 80, height: 80)))
        view.backgroundColor = R.color.brighterBackgroundColor()
        view.layer.cornerRadius = 4
        return view
    }()

    func start() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first
        {
            frame = window.bounds
            containerView.center = center
            window.addSubview(self)
        }
    }

    func stop() {
        removeFromSuperview()
    }

    private func setUp() {
        backgroundColor = .init(white: 0, alpha: 0.7)
        containerView.addSubview(indicatorView)
        indicatorView.center = containerView.center
        addSubview(containerView)
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
