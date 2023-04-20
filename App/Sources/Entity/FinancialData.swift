import Foundation

struct FinancialData {
    let indices: [Index]
    let exchangeRate: Double
    let latestOpeningDate: Date?

    init(indices: [Index] = [], exchangeRate: Double = .zero, latestOpeningDate: Date? = nil) {
        self.indices = indices
        self.exchangeRate = exchangeRate
        self.latestOpeningDate = latestOpeningDate
    }
}
