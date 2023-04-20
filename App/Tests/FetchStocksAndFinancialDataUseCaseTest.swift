@testable import Fintone
import XCTest

final class FetchStocksAndFinancialDataUseCaseTest: XCTestCase {
    var useCase: FetchStocksAndFinancialDataUseCaseProtocol!

    func testFetchWithAPIService() async throws {
        if let apiKeyClass = NSClassFromString("Fintone.APIKey") as? APIKeyProtocol.Type {
            try await testFetch(apiService: APIService(apiKey: apiKeyClass.key))
        } else {
            throw XCTSkip("APIKeyがないのでテストしません")
        }
    }

    func testFetchWithMockAPIService() async throws {
        try await testFetch(apiService: MockAPIService())
    }

    private func testFetch(apiService: APIServiceProtocol) async throws {
        useCase = FetchStocksAndFinancialDataUseCase(apiService: apiService)

        var portfolio: Portfolio
        var result: FetchStocksAndFinancialDataUseCase.FetchResult?

        portfolio = Portfolio(name: "空", orderedSymbols: [], amounts: [:], key: "キー")
        result = try await useCase.execute(with: portfolio)
        XCTAssertNil(result)

        portfolio = Portfolio(
            name: "ポートフォリオ", orderedSymbols: ["AAPL", "MSFT", "SPY"], amounts: ["AAPL": 10, "MSFT": 3, "SPY": 1], key: "キー"
        )
        result = try await useCase.execute(with: portfolio)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.stocks.count, 3)
        XCTAssertEqual(result!.stocks[0].symbol, "AAPL")
        XCTAssertEqual(result!.stocks[0].amount, 10)
        XCTAssertNotNil(result!.stocks[0].logoData)
        XCTAssertTrue(result!.stocks[0].isActivelyTrading)
        XCTAssertTrue(result!.stocks[2].isETF)
        XCTAssertEqual(result!.financialData.indices.count, 3)
        XCTAssertNotNil(result!.financialData.latestOpeningDate)

        portfolio = Portfolio(
            name: "上場廃止・ティッカー変更等銘柄", orderedSymbols: ["TWTR", "FB"], amounts: ["TWTR": 1, "FB": 1], key: "キー"
        )
        result = try await useCase.execute(with: portfolio)
        XCTAssertNotNil(result)
        result!.stocks.forEach {
            XCTAssertEqual($0.currentPrice, 0)
            XCTAssertEqual($0.percentChanges[.daily], 0)
            XCTAssertEqual($0.percentChanges[.weekly], 0)
            XCTAssertEqual($0.percentChanges[.monthly], 0)
            XCTAssertEqual($0.percentChanges[.yearToDate], 0)
            XCTAssertFalse($0.isActivelyTrading)
        }
        XCTAssertEqual(result!.financialData.indices.count, 3)
        XCTAssertNotNil(result!.financialData.latestOpeningDate)
    }
}
