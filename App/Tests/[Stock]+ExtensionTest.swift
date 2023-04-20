@testable import Fintone
import XCTest

final class StockArrayExtensionTest: XCTestCase {
    let stocks = [
        Stock(
            amount: 10,
            symbol: "AAPL",
            name: "アップル",
            logoData: nil,
            currentPrice: 100.00,
            percentChanges: .init(values: [.daily: 3, .weekly: 6, .monthly: -12, .yearToDate: -30]),
            isETF: false,
            isActivelyTrading: true
        ),
        Stock(
            amount: 3,
            symbol: "MSFT",
            name: "マイクロソフト",
            logoData: nil,
            currentPrice: 200,
            percentChanges: .init(values: [.daily: -2, .weekly: 4, .monthly: 8, .yearToDate: 16]),
            isETF: false,
            isActivelyTrading: true
        ),
        Stock(
            amount: 1,
            symbol: "SPY",
            name: "上場投資信託",
            logoData: nil,
            currentPrice: 400,
            percentChanges: .init(values: [.daily: 4, .weekly: 8, .monthly: 16, .yearToDate: 32]),
            isETF: true,
            isActivelyTrading: true
        ),
    ]

    func testMarketValues() {
        zip(stocks.marketValues, [1000.0, 600.0, 400.0]).forEach {
            XCTAssertEqual($0, $1, accuracy: 0.001)
        }
    }

    func testTotalMarketValue() {
        XCTAssertEqual(stocks.totalMarketValue, 2000.0, accuracy: 0.001)
    }

    func testPercentChange() {
        XCTAssertEqual(
            stocks.percentChange(.daily),
            (1000 * 0.03 + 600 * -0.02 + 400 * 0.04) / 2000.0 * 100,
            accuracy: 0.001
        )
    }

    func testProfitOrLoss() {
        XCTAssertEqual(
            stocks.profitOrLoss(.daily),
            1000 * 0.03 + 600 * -0.02 + 400 * 0.04,
            accuracy: 0.001
        )
    }
}
