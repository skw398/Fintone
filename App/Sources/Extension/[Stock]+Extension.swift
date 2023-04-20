import Foundation

extension [Stock] {
    var marketValues: [Double] {
        map(\.marketValue)
    }

    var totalMarketValue: Double {
        reduce(0) { $0 + $1.marketValue }
    }

    func percentChange(_ period: Period) -> Double {
        let totalMarketValue = totalMarketValue
        return reduce(0) { $0 + ($1.percentChanges[period] * $1.marketValue / totalMarketValue) }
    }

    func profitOrLoss(_ period: Period) -> Double {
        totalMarketValue * percentChange(period) / 100
    }
}
