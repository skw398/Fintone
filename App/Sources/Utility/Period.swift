import Foundation

enum Period: CaseIterable {
    case daily, weekly, monthly, yearToDate

    func label(date: Date?) -> String {
        switch self {
        case .daily:
            if let date {
                return "1 Day — " + DateFormatter.mediumDateFormatter.string(from: date)
            }
            return "1 Day"
        case .weekly:
            return "1 Week"
        case .monthly:
            return "1 Month"
        case .yearToDate:
            if let date {
                return "Year to Date for " + DateFormatter.yearFormatter.string(from: date)
            }
            return "Year to Date"
        }
    }

    func colorPercentChangeThreshold() -> Double {
        switch self {
        case .daily:
            return 3.0
        case .weekly:
            return 6.0
        case .monthly:
            return 12.0
        case .yearToDate:
            return 30.0
        }
    }
}

private extension DateFormatter {
    static var mediumDateFormatter: Self {
        let df = Self()
        df.dateStyle = .medium
        df.timeStyle = .none
        df.locale = Locale(identifier: "en_US")
        return df
    }

    static var yearFormatter: Self {
        let df = Self()
        df.dateFormat = "yyyy"
        return df
    }
}
