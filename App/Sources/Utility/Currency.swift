import Foundation

enum Currency: String, CaseIterable {
    case EUR_USD
    case USD_JPY
    case GBP_USD
    case AUD_USD
    case USD_CAD
    case USD_CHF
    
    var name: String {
        rawValue.replacingOccurrences(of: "_", with: "/")
    }
    
    var symbol: String {
        rawValue.replacingOccurrences(of: "_", with: "")
    }
}
