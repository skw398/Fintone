import Foundation

protocol APIServiceProtocol: Sendable {
    func fetchExchangeRate(currency: Currency) async throws -> Double
    func fetchLatestOpeningDate() async throws -> Date?
    func fetchProfiles(forSymbols symbols: [String]) async throws -> [Profile]
    func fetchQuotes(forSymbols symbols: [String]) async throws -> [Quote]
    func fetchStockPriceChanges(forSymbols symbols: [String]) async throws -> [StockPriceChange]
    func fetchStocks(for portfolio: Portfolio) async throws -> [Stock]
    func fetchIndices() async throws -> [Index]
    func downloadLogoData(from profiles: [Profile]) async throws -> [String: Data?]
}
