import Foundation

protocol PortfolioServiceProtocol: Actor {
    func migrate()

    func savePortfolioKeys(keys: [String])
    func getPortfolioKeys() -> [String]
    func setInitialPortfolio() -> Portfolio
    func getPortfolio(key: String) -> Portfolio?
    func getPortfolios() -> [Portfolio]
    func addPortfolio(name: String)
    func updatePortfolio(_ portfolio: Portfolio)
    func deletePortfolio(key: String)
    func reset()
}
