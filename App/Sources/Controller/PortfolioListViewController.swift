import UIKit

final class PortfolioListViewController: UIViewController {
    @IBOutlet private var portfolioListTableView: UITableView!
    @IBOutlet private var addButton: UIBarButtonItem! {
        didSet {
            addButton.primaryAction = .init(
                image: .init(systemName: "plus"),
                handler: { [weak self] _ in
                    guard let count = self?.portfolios.count, count < Constants.maxPortfolioCount else {
                        self?.showExceedMaxPortfolioCountAlert()
                        return
                    }
                    self?.showPortfolioNameInputAlert()
                }
            )
        }
    }

    @IBOutlet private var editButton: UIBarButtonItem! {
        didSet {
            editButton.primaryAction = .init(handler: { [weak self] _ in
                guard let self else { return }
                self.portfolioListTableView.setEditing(!self.portfolioListTableView.isEditing, animated: true)
                self.updateRightBarButtonItem()
            })
            editButton.title = R.string.localizable.edit()
            editButton.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 16, weight: .bold)], for: .normal)
        }
    }

    private var portfolios: [Portfolio] = []

    private let fetchStocksAndFinancialDataUseCase = FetchStocksAndFinancialDataUseCase(
        apiService: ServiceDependencies.apiService
    )

    private var fetchDidSucceedAction: (@MainActor (
        _ key: String, _ data: FetchStocksAndFinancialDataUseCase.FetchResult?
    ) -> Void)!

    func setActions(fetchDidSucceedAction: @escaping @MainActor (
        _ key: String, _ data: FetchStocksAndFinancialDataUseCase.FetchResult?
    ) -> Void) {
        self.fetchDidSucceedAction = fetchDidSucceedAction
    }

    var presentingPortfolioKey: String!

    var portfolioService: PortfolioServiceProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            portfolios = await portfolioService.getPortfolios()
            portfolioListTableView.reloadData()
            updateRightBarButtonItem()
        }
        setUpTableViewFooter()
        navigationItem.title = R.string.localizable.portfolios()
    }

    private func updateRightBarButtonItem() {
        editButton.title = portfolioListTableView.isEditing
            ? R.string.localizable.kanryo()
            : R.string.localizable.edit()
        editButton.isEnabled = portfolios.count > 1
        editButton.tintColor = portfolios.count > 1 ? .white : .clear
    }

    private func showFailedToLoadDataAlert(title: String) {
        let alert = UIAlertController.initWithCloseAction(title: title)
        present(alert, animated: true)
    }

    private func showDeletePortfolioConfirmationAlert(indexPath: IndexPath) {
        let alert = UIAlertController(
            title: portfolios[indexPath.row].name,
            message: R.string.localizable.wantToDeleteThePortfolio(),
            preferredStyle: .alert
        )
        let deleteAction = UIAlertAction(
            title: R.string.localizable.delete(),
            style: .destructive,
            handler: { [weak self] _ in
                self?.didTapDeleteButtonOnDeletePortfolioConfirmationAlert(indexPath: indexPath)
            }
        )
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    private func showExceedMaxPortfolioCountAlert() {
        let alert = UIAlertController.initWithCloseAction(title: R.string.localizable.noMoreThan30Portfolios())
        present(alert, animated: true)
    }

    private func showPortfolioNameInputAlert() {
        let alert = PortfolioNameInputAlertController(
            title: R.string.localizable.newPortfolio(),
            doneActionHandler: didTapDoneButtonOnPortfolioNameInputAlert
        )
        present(alert, animated: true)
    }

    private func didTapDoneButtonOnPortfolioNameInputAlert(name: String) {
        Task {
            await portfolioService.addPortfolio(name: name)
            portfolios = await portfolioService.getPortfolios()
            updateRightBarButtonItem()
            portfolioListTableView.reloadData()
        }
    }

    private func didTapDeleteButtonOnDeletePortfolioConfirmationAlert(indexPath: IndexPath) {
        Task {
            let portfolioToDelete = portfolios[indexPath.row]
            isModalInPresentation = presentingPortfolioKey == portfolioToDelete.key
            await portfolioService.deletePortfolio(key: portfolioToDelete.key)
            portfolios = await portfolioService.getPortfolios()
            portfolioListTableView.deleteRows(at: [indexPath], with: .none)
            if portfolios.count == 1 {
                portfolioListTableView.setEditing(false, animated: true)
            }
            updateRightBarButtonItem()
        }
    }

    private func setUpTableViewFooter() {
        let label = UILabel(frame: CGRect(x: 16, y: 16, width: view.frame.width - 32, height: 0))
        label.text = R.string.localizable.whenTheAppIsLaunched()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.sizeToFit()
        let logoView = LogoView(frame: .init(x: 0, y: label.bounds.height + 16, width: view.bounds.width, height: 90))
        let footerView = UIView(frame: .init(
            origin: .zero,
            size: .init(width: label.bounds.height, height: logoView.bounds.height + 32)
        ))
        footerView.addSubview(label)
        footerView.addSubview(logoView)
        portfolioListTableView.tableFooterView = footerView
    }

    private func didTapPortfolioCell(for indexPath: IndexPath) {
        let cell = portfolioListTableView.cellForRow(at: indexPath) as! PortfoliosTableViewCell
        cell.setContainerViewBackgroundColor(R.color.brighterBackgroundColor()!)

        let portfolio = portfolios[indexPath.row]
        Task {
            let indicatorView = IndicatorView()
            indicatorView.start()
            do {
                let result = try await fetchStocksAndFinancialDataUseCase.execute(with: portfolio)
                if let _ = result { UINotificationFeedbackGenerator().notificationOccurred(.success) }
                fetchDidSucceedAction(portfolio.key, result)
                dismiss(animated: true)
            } catch {
                var errorDescription = R.string.localizable.unexpectedErrorOccurred()
                if let error = error as? APIServiceError {
                    errorDescription = error.localizedDescription
                }
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                showFailedToLoadDataAlert(title: errorDescription)
                portfolioListTableView.reloadData()
            }
            cell.setContainerViewBackgroundColor(R.color.backgroundColor()!)
            indicatorView.stop()
        }
    }
}

extension PortfolioListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        portfolios.count
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = R.nib.portfoliosTableViewCell(withOwner: self)!
        let portfolio = portfolios[indexPath.row]
        cell.updateView(name: portfolio.name, numberOfStocks: portfolio.orderedSymbols.count)
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        70
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        tableView.isEditing ? .delete : .none
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        didTapPortfolioCell(for: indexPath)
    }

    func tableView(_: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        showDeletePortfolioConfirmationAlert(indexPath: indexPath)
    }

    func tableView(_: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        Task {
            var mutablePortfolios = portfolios
            let movedPortfolio = mutablePortfolios.remove(at: sourceIndexPath.row)
            mutablePortfolios.insert(movedPortfolio, at: destinationIndexPath.row)
            let keys = mutablePortfolios.map { $0.key }
            await portfolioService.savePortfolioKeys(keys: keys)
            portfolios = await portfolioService.getPortfolios()
        }
    }

    func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! PortfoliosTableViewCell
        cell.setContainerViewBackgroundColor(R.color.brighterBackgroundColor()!)
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! PortfoliosTableViewCell
        cell.setContainerViewBackgroundColor(R.color.backgroundColor()!)
    }
}
