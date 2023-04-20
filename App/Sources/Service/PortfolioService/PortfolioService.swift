import Foundation

extension PortfolioService {
    func migrate() {
        let keys = getPortfolioKeys()
        keys.forEach { key in
            if let dictionary = store.dictionary(forKey: key),
               let name = dictionary["portfolioName"] as? String, // to "name"
               let orderedSymbols = dictionary["orderedSymbols"] as? [String],
               let amounts = dictionary["amount"] as? [String: Int] // to "amounts"
            {
                updatePortfolio(Portfolio(
                    name: name,
                    orderedSymbols: orderedSymbols,
                    amounts: amounts,
                    key: key
                ))
            }
        }
    }
}

actor PortfolioService: PortfolioServiceProtocol {
    private let store = NSUbiquitousKeyValueStore.default
    private let portfolioKeysKey = "portfolioKeys"

    private let initialStocks: [(symbol: String, amount: Int)] = [
        ("AAPL", 1),
        ("MSFT", 1),
        ("MCD", 1),
        ("QQQ", 1),
        ("SPY", 1),
    ]

    func savePortfolioKeys(keys: [String]) {
        store.set(keys, forKey: portfolioKeysKey)
    }

    func getPortfolioKeys() -> [String] {
        store.array(forKey: portfolioKeysKey) as? [String] ?? []
    }

    func setInitialPortfolio() -> Portfolio {
        let initialPortfolio = Portfolio(
            name: R.string.localizable.initialPortfolio(),
            orderedSymbols: initialStocks.map { $0.symbol },
            amounts: Dictionary(uniqueKeysWithValues: initialStocks),
            key: "initialPortfolio"
        )
        updatePortfolio(initialPortfolio)
        savePortfolioKeys(keys: [initialPortfolio.key])
        return initialPortfolio
    }

    func getPortfolio(key: String) -> Portfolio? {
        guard let portfolioData = store.dictionary(forKey: key),
              let name = portfolioData["name"] as? String,
              let orderedSymbols = portfolioData["orderedSymbols"] as? [String],
              let amounts = portfolioData["amounts"] as? [String: Int]
        else { return nil }
        return Portfolio(name: name, orderedSymbols: orderedSymbols, amounts: amounts, key: key)
    }

    func getPortfolios() -> [Portfolio] {
        getPortfolioKeys().compactMap {
            getPortfolio(key: $0)
        }
    }

    func addPortfolio(name: String) {
        let key = UUID().uuidString
        var keys = getPortfolioKeys()
        keys.append(key)
        savePortfolioKeys(keys: keys)
        let portfolio = Portfolio(name: name, key: key)
        updatePortfolio(portfolio)
    }

    func updatePortfolio(_ portfolio: Portfolio) {
        store.set([
            "name": portfolio.name,
            "orderedSymbols": portfolio.orderedSymbols,
            "amounts": portfolio.amounts,
        ], forKey: portfolio.key)
    }

    func deletePortfolio(key: String) {
        var keys = getPortfolioKeys()
        keys.removeAll(where: { $0 == key })
        savePortfolioKeys(keys: keys)
        store.removeObject(forKey: key)
    }

    func reset() {
        getPortfolioKeys().forEach {
            store.removeObject(forKey: $0)
        }
        store.removeObject(forKey: portfolioKeysKey)
    }
}
