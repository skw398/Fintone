import Foundation

struct PercentChanges {
    let values: [Period: Double]

    subscript(period: Period) -> Double {
        return values[period] ?? 0.0
    }
}
