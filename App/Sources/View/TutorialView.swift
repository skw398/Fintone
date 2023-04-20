import UIKit

final class TutorialView: UIView {
    private let handImage: UIImageView = {
        let imageView = UIImageView(image: .init(systemName: "hand.draw.fill"))
        imageView.tintColor = .white
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(primaryAction: .init(handler: { [weak self] _ in
            AppPreferenceManager.tutorialHasDone = true
            self?.removeFromSuperview()
        }))
        let config = UIImage.SymbolConfiguration(scale: .large)
        let xMark = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
        button.setImage(xMark, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private func setUp() {
        addSubview(handImage)
        addSubview(closeButton)

        NSLayoutConstraint.activate([
            handImage.topAnchor.constraint(equalTo: topAnchor),
            handImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            handImage.widthAnchor.constraint(equalToConstant: 40),
            handImage.heightAnchor.constraint(equalToConstant: 40),

            closeButton.leadingAnchor.constraint(equalTo: handImage.trailingAnchor, constant: 2),
            closeButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 20),
        ])
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
}
