import Foundation

protocol StockSearchUseCaseProtocol {
    func execute(with symbol: String) async throws -> Stock?
}

struct StockSearchUseCase: StockSearchUseCaseProtocol {
    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    func execute(with symbol: String) async throws -> Stock? {
        guard !symbol.isEmpty else { return nil }
        let searchSymbol = symbol.processedSymbolForSearch
        async let asyncProfiles = apiService.fetchProfiles(forSymbols: [searchSymbol])
        async let asyncPriceChanges = apiService.fetchStockPriceChanges(forSymbols: [searchSymbol])
        let (profiles, priceChanges) = try await (asyncProfiles, asyncPriceChanges)
        let logoData = try await apiService.downloadLogoData(from: profiles)
        guard let profile = profiles.first,
              let priceChanges = priceChanges.first,
              profile.currency == "USD",
              profile.isActivelyTrading
        else { return nil }
        return Stock(
            profile: profile, stockPriceChange: priceChanges, logoData: logoData[searchSymbol] ?? nil
        )
    }
}

private extension String {
    var processedSymbolForSearch: Self {
        return self
            .applyingTransform(.fullwidthToHalfwidth, reverse: false)?
            .uppercased()
            // BRK.A, BRK.B, BRKA, BRKB -> BRK-A, BRK-B
            .replacingOccurrences(
                of: "BRK[.]?([AB])",
                with: "BRK-$1",
                options: [.regularExpression]
            ) ?? self
    }
}

private extension Stock {
    init(profile: Profile, stockPriceChange: StockPriceChange, logoData: Data?) {
        self.init(
            amount: 0,
            symbol: profile.symbol,
            name: profile.companyName,
            logoData: logoData,
            currentPrice: profile.price ?? 0,
            percentChanges: PercentChanges(values: [
                .daily: stockPriceChange.daily,
                .weekly: stockPriceChange.weekly,
                .monthly: stockPriceChange.monthly,
                .yearToDate: stockPriceChange.ytd,
            ]),
            isETF: profile.isEtf,
            isActivelyTrading: profile.isActivelyTrading
        )
    }
}
