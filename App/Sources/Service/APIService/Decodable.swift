import Foundation

struct Quote: Decodable {
    let symbol: String
    let name: String
    let price: Double
}

struct Profile: Decodable {
    let symbol: String
    var price: Double? // 上場廃止・ティッカー変更等銘柄はnullが返る場合がある
    let companyName: String
    let currency: String
    let image: URL?
    let isEtf: Bool
    let isActivelyTrading: Bool
}

struct StockPriceChange: Decodable {
    let symbol: String
    let daily: Double
    let weekly: Double
    let monthly: Double
    let ytd: Double

    enum CodingKeys: String, CodingKey {
        case symbol
        case daily = "1D"
        case weekly = "5D"
        case monthly = "1M"
        case ytd
    }
}

struct Historical: Decodable {
    let date: String
}
