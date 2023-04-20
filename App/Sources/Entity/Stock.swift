import Foundation

struct Stock {
    var amount: Int

    let symbol: String
    let name: String
    let logoData: Data?
    let currentPrice: Double
    let percentChanges: PercentChanges
    let isETF: Bool
    let isActivelyTrading: Bool

    var marketValue: Double {
        currentPrice * Double(amount)
    }

    func profitOrLoss(_ period: Period) -> Double {
        currentPrice * Double(amount) * percentChanges[period] / 100
    }
}
