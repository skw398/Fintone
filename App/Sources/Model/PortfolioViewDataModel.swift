import Foundation

final class PortfolioViewDataModel {
    private(set) var portfolio: Portfolio = .init(name: "")
    private(set) var financialData: FinancialData = .init()
    private(set) var stocks: [Stock] = []

    private let portfolioService: PortfolioServiceProtocol

    init(portfolioService: PortfolioServiceProtocol) {
        self.portfolioService = portfolioService
    }

    func applyPortfolio(portfolio: Portfolio) {
        self.portfolio = portfolio
    }

    func updateData(_ data: FetchStocksAndFinancialDataUseCase.FetchResult?) {
        stocks = data?.stocks ?? []
        financialData = data?.financialData ?? .init()
    }

    func sort(by sortType: SortType, period: Period) {
        switch sortType {
        case .profitOrLoss:
            stocks.sort(by: { $0.profitOrLoss(period) > $1.profitOrLoss(period) })
        case .marketValue:
            stocks.sort(by: { $0.marketValue > $1.marketValue })
        case .changePercent:
            stocks.sort(by: { $0.percentChanges[period] > $1.percentChanges[period] })
        case .alphabetical:
            stocks.sort(by: { $1.symbol > $0.symbol })
        case .customOrder:
            stocks = portfolio.orderedSymbols.compactMap { symbol in
                stocks.first(where: { $0.symbol == symbol })
            }
        }
    }

    func addOrUpdate(symbol: String, amount: Int) async {
        portfolio.amounts[symbol] = amount
        if !portfolio.orderedSymbols.contains(symbol) {
            portfolio.orderedSymbols.insert(symbol, at: 0)
        }
        await portfolioService.updatePortfolio(portfolio)
    }

    func removeStock(indexPath: IndexPath) async {
        let stock = stocks.remove(at: indexPath.row)
        portfolio.amounts.removeValue(forKey: stock.symbol)
        portfolio.orderedSymbols.removeAll(where: { $0 == stock.symbol })
        await portfolioService.updatePortfolio(portfolio)
    }

    func moveRowAt(_ sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) async {
        let movingSymbol = portfolio.orderedSymbols.remove(at: sourceIndexPath.row)
        portfolio.orderedSymbols.insert(movingSymbol, at: destinationIndexPath.row)
        let movingStock = stocks.remove(at: sourceIndexPath.row)
        stocks.insert(movingStock, at: destinationIndexPath.row)
        await portfolioService.updatePortfolio(portfolio)
    }

    func updatePortfolioName(newName: String) async {
        portfolio.name = newName
        await portfolioService.updatePortfolio(portfolio)
    }
}
