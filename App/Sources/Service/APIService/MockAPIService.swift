import Foundation
import class UIKit.UIImage

#if DEBUG
    enum MockSymbols {
        static let availableSymbols = [
            "AAPL": "アップル",
            "AMZN": "アマゾン",
            "GOOG": "グーグル",
            "MSFT": "マイクロソフト",
            "META": "メタ",
            "WMT": "ウォルマート",
            "TSLA": "テスラ",
            "KO": "コカコーラ",
            "SBUX": "スターバックス",
            "COST": "コストコ",
            "PYPL": "ペイパル",
            "NKE": "ナイキ",
            "NVDA": "エヌヴィディア",
            "ADBE": "アドビ",
            "INTC": "インテル",
            "DIS": "ディズニー",
            "MCD": "マクドナルド",
            "CSCO": "シスコシステムズ",
            "AXP": "アメリカンエキスプレス",
            "PEP": "ペプシコ",
            "BA": "ボーイング",
            "GS": "ゴールドマンサックス",
            "JNJ": "ジョンソンエンドジョンソン",
            "GM": "ゼネラルモーターズ",
            "HPE": "ヒューレットパッカード",
            "NFLX": "ネットフリックス",
            "MA": "マスターカード",
            "V": "ビザ",
            "JPM": "ジェイピーモルガン",
            "BRK-A": "バークシャーA株",
            "BRK-B": "バークシャーB株",
        ]

        static let availableETFs = ["SPY", "QQQ", "VTI", "ARKK", "ARKG", "VOO", "VWO", "IWM", "EEM", "VNQ"]

        static let unavailableSymbols = [
            "TWTR": "ツイッター（上場廃止）",
            "FB": "FB->META",
        ]
    }

    final class MockAPIService: APIServiceProtocol {
        private let mockStocks: [Stock] = MockSymbols.availableSymbols.map {
            Stock(
                amount: 0,
                symbol: $0.key,
                name: $0.value,
                logoData: UIImage(systemName: "face.smiling.fill")?.jpegData(compressionQuality: 1.0),
                currentPrice: Double.random(in: 50.0 ... 300.0),
                percentChanges: .init(values: [
                    .daily: Double.random(in: -4.0 ... 4.0),
                    .weekly: Double.random(in: -8.0 ... 8.0),
                    .monthly: Double.random(in: -16.0 ... 16.0),
                    .yearToDate: Double.random(in: -40.0 ... 40.0),
                ]),
                isETF: false,
                isActivelyTrading: true
            )
        }

            + MockSymbols.availableETFs.map {
                Stock(
                    amount: 0,
                    symbol: $0,
                    name: "\($0)上場投資信託",
                    logoData: UIImage(systemName: "face.smiling")?.jpegData(compressionQuality: 1.0),
                    currentPrice: Double.random(in: 50.0 ... 300.0),
                    percentChanges: .init(
                        values: [
                            .daily: Double.random(in: -4.0 ... 4.0),
                            .weekly: Double.random(in: -8.0 ... 8.0),
                            .monthly: Double.random(in: -16.0 ... 16.0),
                            .yearToDate: Double.random(in: -40.0 ... 40.0),
                        ]
                    ),
                    isETF: true,
                    isActivelyTrading: true
                )
            }

            + MockSymbols.unavailableSymbols.map {
                Stock(
                    amount: 0,
                    symbol: $0.key,
                    name: $0.value,
                    logoData: UIImage(systemName: "face.smiling.fill")?.jpegData(compressionQuality: 1.0),
                    currentPrice: 0,
                    percentChanges: .init(values: [
                        .daily: 0,
                        .weekly: 0,
                        .monthly: 0,
                        .yearToDate: 0,
                    ]),
                    isETF: false,
                    isActivelyTrading: false // !!
                )
            }

        let mockIndexData: [Index] = zip(["^DJI", "^GSPC", "^IXIC"], ["DOW30", "S&P500", "Nasdaq"]).map {
            Index(
                symbol: $0,
                name: $1,
                currentPrice: Double.random(in: 3000.0 ... 40000.0),
                percentChanges: .init(
                    values: [
                        .daily: Double.random(in: -4.0 ... 4.0),
                        .weekly: Double.random(in: -8.0 ... 8.0),
                        .monthly: Double.random(in: -16.0 ... 16.0),
                        .yearToDate: Double.random(in: -40.0 ... 40.0),
                    ]
                )
            )
        }

        private let mockExchangeRate = Double.random(in: 80.0 ... 200.0)

        private func fakeLatency() async throws {
            try await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
        }

        func fetchStocks(for portfolio: Portfolio) async throws -> [Stock] {
            try await fakeLatency()
            return portfolio.orderedSymbols
                .compactMap { symbol in
                    mockStocks.first(where: { $0.symbol == symbol })
                }
                .map {
                    var mutableStock = $0
                    mutableStock.amount = portfolio.amounts[$0.symbol] ?? 0
                    return mutableStock
                }
        }

        func fetchIndices() async throws -> [Index] {
            try await fakeLatency()
            return mockIndexData
        }

        func fetchExchangeRate() async throws -> Double {
            try await fakeLatency()
            return mockExchangeRate
        }

        func fetchLatestOpeningDate() async throws -> Date? {
            try await fakeLatency()
            return Date(timeIntervalSince1970: 0)
        }

        func fetchProfiles(forSymbols symbols: [String]) async throws -> [Profile] {
            try await fakeLatency()
            return symbols
                .compactMap { symbol in
                    mockStocks.first(where: { $0.symbol == symbol })
                }
                .map {
                    Profile(
                        symbol: $0.symbol,
                        price: $0.currentPrice,
                        companyName: $0.name,
                        currency: "USD",
                        image: nil,
                        isEtf: $0.isETF,
                        isActivelyTrading: $0.isActivelyTrading
                    )
                }
        }

        func fetchQuotes(forSymbols symbols: [String]) async throws -> [Quote] {
            try await fakeLatency()
            return symbols
                .compactMap { symbol in
                    mockStocks.first(where: { $0.symbol == symbol })
                }
                .map {
                    Quote(
                        symbol: $0.symbol,
                        name: $0.name,
                        price: $0.currentPrice
                    )
                }
        }

        func fetchStockPriceChanges(forSymbols symbols: [String]) async throws -> [StockPriceChange] {
            try await fakeLatency()
            return symbols
                .compactMap { symbol in
                    mockStocks.first(where: { $0.symbol == symbol })
                }
                .map {
                    StockPriceChange(
                        symbol: $0.symbol,
                        daily: $0.percentChanges[.daily],
                        weekly: $0.percentChanges[.weekly],
                        monthly: $0.percentChanges[.monthly],
                        ytd: $0.percentChanges[.yearToDate]
                    )
                }
        }

        func downloadLogoData(from profiles: [Profile]) async throws -> [String: Data?] {
            try await fakeLatency()
            return profiles.reduce(into: [:]) { result, profile in
                result[profile.symbol] = {
                    if profile.isEtf {
                        return UIImage(systemName: "face.smiling")?.jpegData(compressionQuality: 1.0)
                    } else {
                        return UIImage(systemName: "face.smiling.fill")?.jpegData(compressionQuality: 1.0)
                    }
                }()
            }
        }
    }
#endif
