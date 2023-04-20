import Foundation

protocol FetchStocksAndFinancialDataUseCaseProtocol {
    func execute(with portfolio: Portfolio) async throws -> FetchStocksAndFinancialDataUseCase.FetchResult?
}

struct FetchStocksAndFinancialDataUseCase: FetchStocksAndFinancialDataUseCaseProtocol {
    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    struct FetchResult {
        var stocks: [Stock]
        var financialData: FinancialData
    }

    func execute(with portfolio: Portfolio) async throws -> FetchResult? {
        guard !portfolio.orderedSymbols.isEmpty else { return nil }
        async let asyncStocks = apiService.fetchStocks(for: portfolio)
        async let asyncIndices = apiService.fetchIndices()
        async let asyncExchangeRate = apiService.fetchExchangeRate()
        async let asyncLatestOpeningDate = apiService.fetchLatestOpeningDate()
        let (stocks, indices, exchangeRate, latestOpeningDate) = try await (
            asyncStocks, asyncIndices, asyncExchangeRate, asyncLatestOpeningDate
        )
        let financialData = FinancialData(
            indices: indices, exchangeRate: exchangeRate, latestOpeningDate: latestOpeningDate
        )
        return .init(stocks: stocks, financialData: financialData)
    }
}
