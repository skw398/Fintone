import SemiCircleChart
import UIKit

final class PortfolioViewController: UIViewController {
    @IBOutlet private var scrollView: UIScrollView!

    @IBOutlet private var headerView: HeaderView!
    @IBOutlet private var indexViews: [IndexView]!
    @IBOutlet private var highlightedSliceInfoView: HighlightedStockView!
    @IBOutlet private var semiCircleChart: SemiCircleChart!
    @IBOutlet private var colorLegendView: ColorLegendView!
    @IBOutlet private var totalView: TotalView!
    @IBOutlet private var helpView: HelpView!
    @IBOutlet private var stockTableView: UITableView!
    @IBOutlet private var toolView: ToolView!

    private lazy var indicatorView = IndicatorView()

    private lazy var launchView: LaunchView = {
        let view = LaunchView()
        view.setActions(
            didTapRetryButtonAction: presenter.didTapRetryButtonOnLaunchView
        )
        return view
    }()

    private lazy var noStocksView: NoStocksView = {
        let view = NoStocksView()
        view.setActions(
            didTapAddStockButtonAction: presenter.didTapAddButtonOnNoStockView
        )
        view.frame = self.view.bounds
        return view
    }()

    private lazy var portfolioNameButton: UIButton = {
        let button = UIButton(primaryAction: .init(handler: { [weak self] _ in
            self?.presenter.didTapPortfolioNameButton()
        }))
        button.setImage(
            .init(systemName: "square.and.pencil", withConfiguration: UIImage.SymbolConfiguration(scale: .small)),
            for: .normal
        )
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        button.semanticContentAttribute = .forceRightToLeft
        return button
    }()

    private var presenter: PortfolioViewPresenterInput!

    func inject(presenter: PortfolioViewPresenterInput) {
        self.presenter = presenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        presenter.viewDidLoad()
    }

    private func configure() {
        stockTableView.delegate = self
        stockTableView.dataSource = self

        navigationItem.leftBarButtonItem = .init(primaryAction: .init(
            image: .init(systemName: "line.3.horizontal"),
            handler: { [weak self] _ in
                self?.presenter.didTapPortfolioListButton()
            }
        ))
        navigationItem.rightBarButtonItem = .init(primaryAction: .init(
            image: .init(systemName: "info.circle"),
            handler: { [weak self] _ in
                self?.presenter.didTapInfoButton()
            }
        ))

        headerView.setActions(
            didTapSelectCurrencyButtonAction: presenter.didTapSelectCurrencyButton
        )
        semiCircleChart.setHighlightedIndexDidChangeHandler(
            highlightedIndexChangedOnPieChartView(index:)
        )
        totalView.setActions(
            didTapSortButtonAction: presenter.didTapSortButtonOnTotalView,
            didTapHelpButtonAction: presenter.didTapHelpButton
        )
        toolView.setActions(
            didTapPeriodButtonAction: presenter.didTapPeriodButton(period:),
            didTapAddButtonAction: presenter.didTapAddButton,
            didTapReloadButtonAction: presenter.didTapReloadButton,
            didTapSortMenuButtonAction: presenter.didTapSortMenuButton
        )
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension PortfolioViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        presenter.stocks.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = R.nib.stockTableViewCell(withOwner: self)!
        cell.updateCell(indexPath: indexPath, stocks: presenter.stocks, period: presenter.selectedPeriod)
        cell.setActions(
            didTapEditButtonAction: presenter.didTapEditButtonOnStockCellMenu(indexPath:),
            didTapDeleteButtonAction: presenter.didTapDeleteButtonOnStockCellMenu(indexPath:),
            didTapWarningButtonAction: presenter.didTapWarningButtonOnStockCell
        )
        return cell
    }

    private var stockTableViewCellHeight: CGFloat { 75 }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        stockTableViewCellHeight
    }
}

// MARK: - HomeViewPresenterOutput

extension PortfolioViewController: PortfolioViewPresenterOutput {
    func showLaunchView() {
        launchView.show()
    }

    func hideLaunchView() {
        launchView.hide()
    }

    func updateLaunchViewForLoadFailureState(title: String) {
        launchView.failedToLoad(title: title)
    }

    func playWarningNotificationFeedback() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    func playSuccessNotificationFeedback() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func startIndicator() {
        indicatorView.start()
    }

    func stopIndicator() {
        indicatorView.stop()
    }

    func scrollToTop() {
        scrollView.setContentOffset(.zero, animated: false)
    }

    func showDeleteStockAlert(title: String, message: String, deleteActionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = .dark
        let deleteAction = UIAlertAction(
            title: R.string.localizable.delete(),
            style: .destructive,
            handler: { _ in deleteActionHandler() }
        )
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    func updateView() {
        updatePortfolioNameButton()
        guard !checkPortfolioIsEmptyAndToggleNoStocksViewVisibility() else { return }
        updateHeaderView()
        updateIndexViews()
        updatePieChartView()
        updateHighlightedStockView()
        showTutorialViewIfNotTutorialHasDone()
        toggleHelpViewVisibility()
        updateColorLegendView()
        updateTotalView()
        updateStocksTableView()
        updateToolView()
    }

    func updatePortfolioNameButton() {
        portfolioNameButton.setTitle("\(presenter.portfolio.name) ", for: .normal)
        navigationItem.titleView = nil
        navigationItem.titleView = portfolioNameButton
    }

    func toggleHelpViewVisibility() {
        helpView.isHidden = AppPreferenceManager.helpViewIsHidden
    }

    func showAlert(title: String, message: String? = nil) {
        let alert = UIAlertController.initWithCloseAction(title: title, message: message)
        present(alert, animated: true)
    }

    func showAlertOnPresentedViewController(title: String) {
        if let nav = presentedViewController as? UINavigationController {
            let alert = UIAlertController.initWithCloseAction(title: title)
            nav.topViewController?.present(alert, animated: true)
        }
    }

    func showPortfolioNameInputAlert(title: String, doneActionHandler: @escaping (_ name: String) -> Void) {
        let alert = PortfolioNameInputAlertController(
            title: title, portfolio: presenter.portfolio, doneActionHandler: doneActionHandler
        )
        present(alert, animated: true)
    }

    func presentInputAmountViewController(with stock: Stock) {
        let vc = R.storyboard.inputAmountViewController.instantiateInitialViewController()!
        vc.portfolio = presenter.portfolio
        vc.stock = stock
        vc.setActions(
            didTapEnterButtonAction: presenter.didTapEnterButtonOnInputAmountView(symbol:amount:)
        )
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }

    func presentStockSearchViewController() {
        let vc = R.storyboard.stockSearchViewController.instantiateInitialViewController()!
        vc.modalPresentationStyle = .overFullScreen
        vc.setAction(
            didFindStockAction: presenter.didFindStockOnStockSearchView(stock:)
        )
        vc.existingSymbols = presenter.portfolio.orderedSymbols
        present(vc, animated: true)
    }

    func presentSortViewController() {
        let vc = R.storyboard.sortViewController.instantiateInitialViewController()!
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        vc.rowDidMoveHandler = presenter.didMoveRowOnSortView
        vc.stocks = presenter.stocks
        present(vc, animated: true)
    }

    func presentPortfolioListView() {
        let nav = R.storyboard.portfolioListViewController.instantiateInitialViewController()!
        if let sheet = nav.sheetPresentationController {
            sheet.prefersGrabberVisible = true
        }
        let vc = nav.topViewController as! PortfolioListViewController
        vc.presentingPortfolioKey = presenter.portfolio.key
        vc.portfolioService = ServiceDependencies.portfolioService
        vc.setActions(
            fetchDidSucceedAction: presenter.fetchDidSucceedOnPortfolioListView(key:data:)
        )
        present(nav, animated: true)
    }

    func presentInfoView() {
        let nav = R.storyboard.infoViewController.instantiateInitialViewController()!
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }
}

// MARK: - View Updates

extension PortfolioViewController {
    private func updateHeaderView() {
        headerView.updateView(financialData: presenter.financialData, period: presenter.selectedPeriod)
    }

    private func updateIndexViews() {
        zip(indexViews, presenter.financialData.indices).forEach { view, data in
            view.updateView(index: data, period: presenter.selectedPeriod)
        }
    }

    private func updatePieChartView() {
        let period = presenter.selectedPeriod
        semiCircleChart.holeColor = .byPercentChange(presenter.stocks.percentChange(period), period: period)
        semiCircleChart.backgroundColor = R.color.backgroundColor()
        let items = presenter.stocks.map { SemiCircleChart.Item(
            value: $0.marketValue,
            color: .byPercentChange($0.percentChanges[period], period: period)
        ) }
        semiCircleChart.draw(items)
        semiCircleChart.fadeIn(withDuration: 0.3)
    }

    private func highlightedIndexChangedOnPieChartView(index: Int?) {
        highlightedSliceInfoView.updateView(
            stocks: presenter.stocks, period: presenter.selectedPeriod, highlightedIndex: index
        )
        scrollView.isScrollEnabled = index == nil
    }

    private func updateHighlightedStockView(highlightedIndex: Int? = nil) {
        highlightedSliceInfoView.updateView(
            stocks: presenter.stocks, period: presenter.selectedPeriod, highlightedIndex: highlightedIndex
        )
    }

    private func updateColorLegendView() {
        colorLegendView.updateLabel(period: presenter.selectedPeriod)
    }

    private func showTutorialViewIfNotTutorialHasDone() {
        let width: CGFloat = 62
        if !AppPreferenceManager.tutorialHasDone {
            let tutorialView = TutorialView(frame: .init(
                x: view.bounds.width / 2 - width, y: semiCircleChart.bounds.height / 2 - 16, width: width, height: 40
            ))
            semiCircleChart.addSubview(tutorialView)
        }
    }

    private func updateTotalView() {
        totalView.updateView(stocks: presenter.stocks, period: presenter.selectedPeriod)
    }

    private func updateStocksTableView() {
        if let heightConstraint = stockTableView.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = stockTableViewCellHeight * CGFloat(presenter.stocks.count)
        }
        stockTableView.reloadData()
    }

    private func updateToolView() {
        toolView.updatePeriodButtons(selectedPeriod: presenter.selectedPeriod)
    }

    private func checkPortfolioIsEmptyAndToggleNoStocksViewVisibility() -> Bool {
        let portfolioIsEmpty = presenter.stocks.isEmpty
        if portfolioIsEmpty {
            view.addSubview(noStocksView)
        } else {
            noStocksView.removeFromSuperview()
        }
        return portfolioIsEmpty
    }
}
