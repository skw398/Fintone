import Foundation

@MainActor protocol PortfolioViewPresenterInput {
    var portfolio: Portfolio { get }
    var financialData: FinancialData { get }
    var stocks: [Stock] { get }
    var selectedPeriod: Period { get }

    func viewDidLoad()
    func didTapRetryButtonOnLaunchView()
    func didTapPortfolioNameButton()
    func didTapSelectCurrencyButton()
    func didTapAddButtonOnNoStockView()
    func didTapWarningButtonOnStockCell()
    func didMoveRowOnSortView(moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    func didTapPortfolioListButton()
    func didTapInfoButton()
    func didTapSortButtonOnTotalView()
    func didTapHelpButton()
    func didTapPeriodButton(period: Period)
    func didTapAddButton()
    func didTapReloadButton()
    func didTapSortMenuButton()
    func didTapEnterButtonOnInputAmountView(symbol: String, amount: Int)
    func fetchDidSucceedOnPortfolioListView(key: String, data: FetchStocksAndFinancialDataUseCase.FetchResult?)
    func didFindStockOnStockSearchView(stock: Stock)
    func didTapEditButtonOnStockCellMenu(indexPath: IndexPath)
    func didTapDeleteButtonOnStockCellMenu(indexPath: IndexPath)
}

@MainActor final class PortfolioViewPresenter {
    private weak var view: PortfolioViewPresenterOutput!
    private let portfolioService: PortfolioServiceProtocol

    private lazy var model: PortfolioViewDataModel = .init(portfolioService: portfolioService)
    private lazy var fetchStocksAndFinancialDataUseCase = FetchStocksAndFinancialDataUseCase(
        apiService: ServiceDependencies.apiService
    )

    init(view: PortfolioViewPresenterOutput, portfolioService: PortfolioServiceProtocol) {
        self.view = view
        self.portfolioService = portfolioService
    }

    private var _selectedPeriod: Period = .daily
    private var selectedSortType: SortType { AppPreferenceManager.sortType }

    private func fetchOnLaunch() async {
        do {
            let data = try await fetchStocksAndFinancialDataUseCase.execute(with: portfolio)
            model.updateData(data)
            model.sort(by: selectedSortType, period: selectedPeriod)
            view.playSuccessNotificationFeedback()
            view.updateView()
            view.hideLaunchView()
        } catch {
            var errorDescription = R.string.localizable.unexpectedErrorOccurred()
            if let error = error as? APIServiceError {
                errorDescription = error.localizedDescription
            }
            view.playWarningNotificationFeedback()
            view.updateLaunchViewForLoadFailureState(title: errorDescription)
        }
    }

    private func fetchOnReload() async {
        view.startIndicator()
        do {
            let data = try await fetchStocksAndFinancialDataUseCase.execute(with: portfolio)
            model.updateData(data)
            model.sort(by: selectedSortType, period: selectedPeriod)
            view.playSuccessNotificationFeedback()
            view.updateView()
        } catch {
            var errorDescription = R.string.localizable.unexpectedErrorOccurred()
            if let error = error as? APIServiceError {
                errorDescription = error.localizedDescription
            }
            view.playWarningNotificationFeedback()
            view.showAlert(title: errorDescription, message: nil)
        }
        view.stopIndicator()
    }
}

// MARK: - PortfolioViewPresenterInput

extension PortfolioViewPresenter: PortfolioViewPresenterInput {
    var portfolio: Portfolio { model.portfolio }
    var financialData: FinancialData { model.financialData }
    var stocks: [Stock] { model.stocks }
    var selectedPeriod: Period { _selectedPeriod }

    func viewDidLoad() {
        view.showLaunchView()

        Task {
            await portfolioService.migrate()
            if let key = await portfolioService.getPortfolioKeys().first,
               let portfolio = await portfolioService.getPortfolio(key: key)
            {
                // Existing user
                model.applyPortfolio(portfolio: portfolio)
            } else {
                // New user
                let initialPortfolio = await portfolioService.setInitialPortfolio()
                model.applyPortfolio(portfolio: initialPortfolio)
            }

            await fetchOnLaunch()
        }
    }

    func didTapRetryButtonOnLaunchView() {
        Task { await fetchOnLaunch() }
    }

    func didTapPortfolioNameButton() {
        view.showPortfolioNameInputAlert(
            title: R.string.localizable.rename(),
            doneActionHandler: { [weak self] newName in
                guard let self else { return }
                Task {
                    await self.model.updatePortfolioName(newName: newName)
                    self.view.updatePortfolioNameButton()
                }
            }
        )
    }
    
    func didTapSelectCurrencyButton() {
        Task { await fetchOnReload() }
    }

    func didTapAddButtonOnNoStockView() {
        view.presentStockSearchViewController()
    }

    func didTapWarningButtonOnStockCell() {
        view.showAlert(title: R.string.localizable.pleaseRemoveTheStock(), message: nil)
    }

    func didMoveRowOnSortView(moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        Task {
            await model.moveRowAt(sourceIndexPath, to: destinationIndexPath)
            view.updateView()
        }
    }

    func didTapPortfolioListButton() {
        view.presentPortfolioListView()
    }

    func didTapInfoButton() {
        view.presentInfoView()
    }

    func didTapSortButtonOnTotalView() {
        view.presentSortViewController()
    }

    func didTapHelpButton() {
        view.toggleHelpViewVisibility()
    }

    func didTapPeriodButton(period: Period) {
        if period != selectedPeriod {
            _selectedPeriod = period
            model.sort(by: selectedSortType, period: selectedPeriod)
            view.updateView()
        }
    }

    func didTapAddButton() {
        guard stocks.count < Constants.maxSymbolCountPerPortfolio else {
            view.showAlert(title: R.string.localizable.exceedMaxSymbolCount(), message: nil)
            return
        }
        view.presentStockSearchViewController()
    }

    func didTapReloadButton() {
        Task { await fetchOnReload() }
    }

    func didTapSortMenuButton() {
        model.sort(by: selectedSortType, period: selectedPeriod)
        view.updateView()
    }

    func didTapEnterButtonOnInputAmountView(symbol: String, amount: Int) {
        let previous = portfolio
        Task {
            await model.addOrUpdate(symbol: symbol, amount: amount)
            let new = portfolio
            if previous.amounts != new.amounts {
                await fetchOnReload()
            }
        }
    }

    func fetchDidSucceedOnPortfolioListView(key: String, data: FetchStocksAndFinancialDataUseCase.FetchResult?) {
        _selectedPeriod = .daily
        Task {
            if let portfolio = await portfolioService.getPortfolio(key: key) {
                model.applyPortfolio(portfolio: portfolio)
            }
            model.updateData(data)
            model.sort(by: selectedSortType, period: selectedPeriod)
            view.updatePortfolioNameButton()
            view.updateView()
        }
        view.scrollToTop()
    }

    func didFindStockOnStockSearchView(stock: Stock) {
        view.presentInputAmountViewController(with: stock)
    }

    func didTapEditButtonOnStockCellMenu(indexPath: IndexPath) {
        view.presentInputAmountViewController(with: stocks[indexPath.row])
    }

    func didTapDeleteButtonOnStockCellMenu(indexPath: IndexPath) {
        view.showDeleteStockAlert(
            title: stocks[indexPath.row].symbol,
            message: R.string.localizable.wantToDeleteTheStock(),
            deleteActionHandler: { [weak self] in
                guard let self else { return }
                Task {
                    await self.model.removeStock(indexPath: indexPath)
                    self.view.updateView()
                }
            }
        )
    }
}
