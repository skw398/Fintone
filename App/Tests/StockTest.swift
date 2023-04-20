@testable import Fintone
import XCTest

final class StockTest: XCTestCase {
    func makeStock(amount: Int = 2, currentPrice: Double = 50, dailyPercentChange: Double = 1.23) -> Stock {
        Stock(
            amount: amount,
            symbol: "AAPL",
            name: "アップル",
            logoData: nil,
            currentPrice: currentPrice,
            percentChanges: .init(values: [.daily: dailyPercentChange, .weekly: 6, .monthly: -12, .yearToDate: -30]),
            isETF: false,
            isActivelyTrading: true
        )
    }

    func testMarketValue() {
        XCTAssertEqual(makeStock().marketValue, 100.0, accuracy: 0.001)
    }

    func testProfitOrLoss() {
        XCTAssertEqual(makeStock().profitOrLoss(.daily), 1.23, accuracy: 0.001)
        XCTAssertEqual(makeStock().profitOrLoss(.weekly), 6.0, accuracy: 0.001)
        XCTAssertEqual(makeStock().profitOrLoss(.monthly), -12.0, accuracy: 0.001)
        XCTAssertEqual(makeStock().profitOrLoss(.yearToDate), -30.0, accuracy: 0.001)
    }

    func testFormattedStockAmount() {
        XCTAssertEqual(makeStock(amount: 123).formattedAmount, "123")
        XCTAssertEqual(makeStock(amount: 1234).formattedAmount, "1.2K")
        XCTAssertEqual(makeStock(amount: 1_234_567).formattedAmount, "1.2M")
    }

    func testFormattedStockPrice() {
        XCTAssertEqual(makeStock(currentPrice: 1.234).formattedPrice, "1.23")
        XCTAssertEqual(makeStock(currentPrice: 123.456).formattedPrice, "123.46")
        XCTAssertEqual(makeStock(currentPrice: 1234.567).formattedPrice, "1234.57")
    }

    func testFormattedStockPercentChange() {
        XCTAssertEqual(makeStock(dailyPercentChange: 1.234).formattedPercentChange(.daily), "+1.23%")
        XCTAssertEqual(makeStock(dailyPercentChange: 4.567).formattedPercentChange(.daily), "+4.57%")
        XCTAssertEqual(makeStock(dailyPercentChange: -1.234).formattedPercentChange(.daily), "-1.23%")
        XCTAssertEqual(makeStock(dailyPercentChange: -4.567).formattedPercentChange(.daily), "-4.57%")
    }

    func testFormattedStockMarketValue() {
        XCTAssertEqual(makeStock().formattedMarketValue, "$100.00")
        XCTAssertEqual(makeStock(currentPrice: 500).formattedMarketValue, "$1.00K")
        XCTAssertEqual(makeStock(currentPrice: 500_000).formattedMarketValue, "$1.00M")
    }

    func testFormattedStockProfitOrLoss() {
        XCTAssertEqual(makeStock(dailyPercentChange: 1.23).formattedProfitOrLoss(.daily), "+$1.23")
        XCTAssertEqual(makeStock(dailyPercentChange: -1.23).formattedProfitOrLoss(.daily), "-$1.23")
        XCTAssertEqual(makeStock(dailyPercentChange: 1234.56).formattedProfitOrLoss(.daily), "+$1.23K")
        XCTAssertEqual(makeStock(dailyPercentChange: -1234.56).formattedProfitOrLoss(.daily), "-$1.23K")
        XCTAssertEqual(makeStock(dailyPercentChange: 1_234_567.89).formattedProfitOrLoss(.daily), "+$1.23M")
        XCTAssertEqual(makeStock(dailyPercentChange: -1_234_567.89).formattedProfitOrLoss(.daily), "-$1.23M")
    }
}
