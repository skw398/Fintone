import Foundation

struct AppPreferenceManager {
    private enum Preference: String {
        case sortType
        case currency
        case tutorialHasDone
        case helpViewIsHidden
    }

    private static let userDefaults = UserDefaults.standard

    static var sortType: SortType {
        get {
            let rawValue = userDefaults.integer(forKey: Preference.sortType.rawValue)
            if let sortType = SortType(rawValue: rawValue) {
                return sortType
            }
            return .customOrder
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Preference.sortType.rawValue)
        }
    }
    
    static var currency: Currency {
        get {
            if let rawValue = userDefaults.string(forKey: Preference.currency.rawValue),
               let currency = Currency(rawValue: rawValue) {
                return currency
            }
            return .EUR_USD
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Preference.currency.rawValue)
        }
    }

    static var tutorialHasDone: Bool {
        get {
            userDefaults.bool(forKey: Preference.tutorialHasDone.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Preference.tutorialHasDone.rawValue)
        }
    }

    static var helpViewIsHidden: Bool {
        get {
            userDefaults.bool(forKey: Preference.helpViewIsHidden.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Preference.helpViewIsHidden.rawValue)
        }
    }
}
