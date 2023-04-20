import Foundation

#if DEBUG
    actor InMemoryPortfolioService: PortfolioServiceProtocol {
        func migrate() {}

        private var portfolioKeys: [String] = []
        private var portfolios: [String: Portfolio] = [:]

        private let initialStocks: [(symbol: String, amount: Int)] = [
            ("AAPL", 1),
            ("MSFT", 1),
            ("MCD", 1),
            ("QQQ", 1),
            ("SPY", 1),
            ("TWTR", 1),
        ]

        func savePortfolioKeys(keys: [String]) {
            portfolioKeys = keys
        }

        func getPortfolioKeys() -> [String] {
            portfolioKeys
        }

        func setInitialPortfolio() -> Portfolio {
            let initialPortfolio = Portfolio(
                name: R.string.localizable.initialPortfolio(),
                orderedSymbols: initialStocks.map { $0.symbol },
                amounts: Dictionary(uniqueKeysWithValues: initialStocks),
                key: "initialPortfolio"
            )
            portfolioKeys.append(initialPortfolio.key)
            portfolios[initialPortfolio.key] = initialPortfolio
            return initialPortfolio
        }

        func getPortfolios() -> [Portfolio] {
            portfolioKeys.compactMap {
                portfolios[$0]
            }
        }

        func getPortfolio(key: String) -> Portfolio? {
            portfolios[key]
        }

        func addPortfolio(name: String) {
            let key = UUID().uuidString
            portfolioKeys.append(key)
            let portfolio = Portfolio(name: name, orderedSymbols: [], amounts: [:], key: key)
            portfolios[key] = portfolio
        }

        func updatePortfolio(_ portfolio: Portfolio) {
            portfolios[portfolio.key] = portfolio
        }

        func removeSymbol(_ symbol: String, from portfolio: Portfolio) -> Portfolio {
            var portfolio = portfolio
            portfolio.amounts.removeValue(forKey: symbol)
            portfolio.orderedSymbols.removeAll(where: { $0 == symbol })
            updatePortfolio(portfolio)
            return portfolio
        }

        func deletePortfolio(key: String) {
            portfolioKeys.removeAll(where: { $0 == key })
            portfolios.removeValue(forKey: key)
        }

        func reset() {
            portfolioKeys.removeAll()
            portfolios.removeAll()
        }
    }
#endif
