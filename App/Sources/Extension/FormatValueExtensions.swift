import Foundation

extension Stock {
    var formattedAmount: String {
        amount.formatAsAmount
    }

    var formattedPrice: String {
        currentPrice.formatAsPrice
    }

    func formattedPercentChange(_ period: Period) -> String {
        percentChanges[period].formatAsPercentChange
    }

    var formattedMarketValue: String {
        marketValue.formatAsMarketValue
    }

    func formattedProfitOrLoss(_ period: Period) -> String {
        profitOrLoss(period).formatAsProfitOrLoss
    }
}

extension Index {
    var formattedPrice: String {
        currentPrice.formatAsPrice
    }

    func formattedPercentChange(_ period: Period) -> String {
        percentChanges[period].formatAsPercentChange
    }
}

extension [Stock] {
    func formattedPercentChange(_ period: Period) -> String {
        percentChange(period).formatAsPercentChange
    }

    var formattedTotalMarketValue: String {
        totalMarketValue.formatAsMarketValue
    }

    func formattedProfitOrLoss(_ period: Period) -> String {
        profitOrLoss(period).formatAsProfitOrLoss
    }
}

private extension Double {
    var formatAsPrice: String {
        String(format: "%.2f", self)
    }

    var formatAsPercentChange: String {
        (self < 0 ? "-" : "+") + String(format: "%.2f", fabs(self)) + "%"
    }

    var formatAsMarketValue: String {
        if self < 1000 {
            let value = floor(self * 100) / 100
            return "\(String(format: "$%.2f", value))"
        } else if self < 1_000_000 {
            let value = floor(self / 1000 * 100) / 100
            return "\(String(format: "$%.2fK", value))"
        } else {
            let value = floor(self / 1_000_000 * 100) / 100
            return "\(String(format: "$%.2fM", value))"
        }
    }

    var formatAsProfitOrLoss: String {
        let prefix = (self < 0 ? "-" : "+")
        let absolute = fabs(self)

        if absolute < 1000 {
            let value = floor(absolute * 100) / 100
            return prefix + String(format: "$%.2f", value)
        } else if absolute < 1_000_000 {
            let value = floor(absolute / 1000 * 100) / 100
            return prefix + String(format: "$%.2fK", value)
        } else {
            let value = floor(absolute / 1_000_000 * 100) / 100
            return prefix + String(format: "$%.2fM", value)
        }
    }
}

private extension Int {
    var formatAsAmount: String {
        if self < 1000 {
            return description
        } else if self < 1_000_000 {
            let value = floor(Double(self) / 1000 * 10) / 10
            return String(format: "%.1fK", value)
        } else {
            let value = floor(Double(self) / 1_000_000 * 10) / 10
            return String(format: "%.1fM", value)
        }
    }
}
