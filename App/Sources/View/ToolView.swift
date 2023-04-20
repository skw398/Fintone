import UIKit

final class ToolView: UIView {
    @IBOutlet private var periodButtons: [UIButton]!
    @IBOutlet private var sortButton: UIButton!
    @IBOutlet private var addButton: UIButton!
    @IBOutlet private var reloadButton: UIButton!

    private var selectedSortType: SortType { AppPreferenceManager.sortType }

    private let selectedPeriodButtonFont = UIFont.systemFont(ofSize: 22, weight: .black)
    private let defaultPeriodButtonFont = UIFont.systemFont(ofSize: 15, weight: .medium)

    func setActions(
        didTapPeriodButtonAction: @escaping @MainActor (_ period: Period) -> Void,
        didTapAddButtonAction: @escaping @MainActor () -> Void,
        didTapReloadButtonAction: @escaping @MainActor () -> Void,
        didTapSortMenuButtonAction: @escaping @MainActor () -> Void
    ) {
        periodButtons.forEach { button in
            button.addAction(.init(handler: { [weak self] _ in
                guard let self else { return }
                let period = Period.allCases[self.periodButtons.firstIndex(of: button)!]
                didTapPeriodButtonAction(period)
            }), for: .touchUpInside)
        }

        addButton.addAction(.init(handler: { _ in
            didTapAddButtonAction()
        }), for: .touchUpInside)

        reloadButton.addAction(.init(handler: { _ in
            didTapReloadButtonAction()
        }), for: .touchUpInside)

        configureMenuButton(action: didTapSortMenuButtonAction)
    }

    func updatePeriodButtons(selectedPeriod: Period) {
        zip(Period.allCases, periodButtons).forEach { period, button in
            let isSelected = selectedPeriod == period
            button.titleLabel?.font = isSelected ? selectedPeriodButtonFont : defaultPeriodButtonFont
        }
    }

    private func configureMenuButton(action: @escaping @MainActor () -> Void) {
        let actions: [UIAction] = SortType.allCases.reversed().map { sortType in
            .init(
                title: sortType.sortTypeName,
                image: .init(systemName: sortType.iconImageName),
                state: self.selectedSortType == sortType ? .on : .off,
                handler: { [weak self] _ in
                    AppPreferenceManager.sortType = sortType
                    action()
                    self?.configureMenuButton(action: action)
                }
            )
        }
        let items = UIMenu(options: .displayInline, children: actions)
        sortButton.menu = UIMenu(title: "", children: [items])
        sortButton.showsMenuAsPrimaryAction = true
    }

    private func setUp() {
        let view = R.nib.toolView(withOwner: self)!
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
