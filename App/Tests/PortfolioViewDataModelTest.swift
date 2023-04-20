@testable import Fintone
import XCTest

final class PortfolioViewDataModelTest: XCTestCase {
    var model: PortfolioViewDataModel!

    let portfolioService = InMemoryPortfolioService()

    let portfolio: Portfolio = .init(
        name: "ポートフォリオ",
        orderedSymbols: ["AAPL", "MSFT", "SPY"],
        amounts: ["AAPL": 10, "MSFT": 3, "SPY": 1],
        key: "キー"
    )

    let stocks: [Stock] = [
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

    let indices: [Index] = [
        Index(
            symbol: "", name: "DOW30",
            currentPrice: 30000,
            percentChanges: .init(values: [.daily: 3, .weekly: 6, .monthly: -12, .yearToDate: -30])
        ),
        Index(
            symbol: "", name: "S&P500",
            currentPrice: 4000,
            percentChanges: .init(values: [.daily: 3, .weekly: 6, .monthly: -12, .yearToDate: -30])
        ),
        Index(
            symbol: "", name: "NASDAQ",
            currentPrice: 10000,
            percentChanges: .init(values: [.daily: 3, .weekly: 6, .monthly: -12, .yearToDate: -30])
        ),
    ]

    override func setUp() async throws {
        let model = PortfolioViewDataModel(portfolioService: portfolioService)

        model.applyPortfolio(portfolio: portfolio)

        model.updateData(
            .init(
                stocks: stocks,
                financialData: .init(
                    indices: indices,
                    exchangeRate: 123.45,
                    latestOpeningDate: Date()
                )
            )
        )

        await portfolioService.addPortfolio(name: portfolio.name)
        await portfolioService.updatePortfolio(portfolio)

        self.model = model
    }

    func testUpdateData() {
        model.updateData(
            .init(
                stocks: [
                    Stock(
                        amount: 1,
                        symbol: "KO",
                        name: "コカコーラ",
                        logoData: nil,
                        currentPrice: 999.99,
                        percentChanges: .init(values: [.daily: 3, .weekly: 6, .monthly: -12, .yearToDate: -30]),
                        isETF: false,
                        isActivelyTrading: true
                    ),
                ],
                financialData: .init(
                    indices: indices,
                    exchangeRate: 999.99,
                    latestOpeningDate: Date()
                )
            )
        )
        XCTAssertEqual(model.stocks.count, 1)
        XCTAssertEqual(model.stocks[0].name, "コカコーラ")
        XCTAssertEqual(model.stocks[0].currentPrice, 999.99)
        XCTAssertEqual(model.financialData.exchangeRate, 999.99)

        model.updateData(nil)
        XCTAssertTrue(model.stocks.isEmpty)
        XCTAssertTrue(model.financialData.indices.isEmpty)
        XCTAssertEqual(model.financialData.exchangeRate, .zero)
        XCTAssertEqual(model.financialData.latestOpeningDate, nil)
    }

    func testSort() {
        model.sort(by: .customOrder, period: .daily)
        XCTAssertEqual(model.stocks.map(\.symbol), ["AAPL", "MSFT", "SPY"])
        model.sort(by: .alphabetical, period: .daily)
        XCTAssertEqual(model.stocks.map(\.symbol), ["AAPL", "MSFT", "SPY"])
        model.sort(by: .changePercent, period: .daily)
        XCTAssertEqual(model.stocks.map(\.symbol), ["SPY", "AAPL", "MSFT"])
        model.sort(by: .marketValue, period: .daily)
        XCTAssertEqual(model.stocks.map(\.symbol), ["AAPL", "MSFT", "SPY"])
        model.sort(by: .profitOrLoss, period: .daily)
        XCTAssertEqual(model.stocks.map(\.symbol), ["AAPL", "SPY", "MSFT"])
    }

    func testAddOrUpdate() async {
        await model.addOrUpdate(symbol: "KO", amount: 5)
        XCTAssertEqual(model.portfolio.orderedSymbols, ["KO", "AAPL", "MSFT", "SPY"])
        XCTAssertEqual(model.portfolio.amounts, ["KO": 5, "AAPL": 10, "MSFT": 3, "SPY": 1])
        await model.addOrUpdate(symbol: "AAPL", amount: 100)
        XCTAssertEqual(model.portfolio.orderedSymbols, ["KO", "AAPL", "MSFT", "SPY"])
        XCTAssertEqual(model.portfolio.amounts, ["KO": 5, "AAPL": 100, "MSFT": 3, "SPY": 1])

        let portfolio = await portfolioService.getPortfolio(key: "キー")!
        XCTAssertEqual(portfolio.orderedSymbols, ["KO", "AAPL", "MSFT", "SPY"])
        XCTAssertEqual(portfolio.amounts, ["KO": 5, "AAPL": 100, "MSFT": 3, "SPY": 1])
    }

    func testRemoveStock() async {
        await model.removeStock(indexPath: .init(row: 1, section: 0))
        XCTAssertEqual(model.portfolio.orderedSymbols, ["AAPL", "SPY"])
        XCTAssertEqual(model.portfolio.amounts, ["AAPL": 10, "SPY": 1])

        let portfolio = await portfolioService.getPortfolio(key: "キー")!
        XCTAssertEqual(portfolio.orderedSymbols, ["AAPL", "SPY"])
        XCTAssertEqual(portfolio.amounts, ["AAPL": 10, "SPY": 1])
    }

    func testMoveRow() async {
        await model.moveRowAt(.init(row: 2, section: 0), to: .init(row: 0, section: 0))
        await model.moveRowAt(.init(row: 0, section: 0), to: .init(row: 1, section: 0))
        XCTAssertEqual(model.portfolio.orderedSymbols, ["AAPL", "SPY", "MSFT"])
        XCTAssertEqual(model.stocks.map(\.symbol), ["AAPL", "SPY", "MSFT"])

        let portfolio = await portfolioService.getPortfolio(key: "キー")!
        XCTAssertEqual(portfolio.orderedSymbols, ["AAPL", "SPY", "MSFT"])
    }

    func testUpdatePortfolioName() async {
        await model.updatePortfolioName(newName: "新しい名前")
        XCTAssertEqual(model.portfolio.name, "新しい名前")

        let portfolio = await portfolioService.getPortfolio(key: "キー")!
        XCTAssertEqual(portfolio.name, "新しい名前")
    }
}
