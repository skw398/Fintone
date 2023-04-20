@testable import Fintone
import XCTest

final class StockSearchUseCaseTest: XCTestCase {
    var useCase: StockSearchUseCase!

    func testSearchWithAPIService() async throws {
        if let apiKeyClass = NSClassFromString("Fintone.APIKey") as? APIKeyProtocol.Type {
            useCase = StockSearchUseCase(apiService: APIService(apiKey: apiKeyClass.key))
            try await testSearch()
        } else {
            throw XCTSkip("APIKeyがないのでテストしません")
        }
    }

    func testSearchWithMockAPIService() async throws {
        useCase = StockSearchUseCase(apiService: MockAPIService())
        try await testSearch()
    }

    private func testSearch() async throws {
        let nilExpected = ["", " ", "!@#$%^&*()_+", "存在しないシンボル",
                           // "isActivelyTrading": false
                           "TWTR",
                           // "currency": "CAD"
                           "RY.TO"]
        let AAPLCaseVariations = ["AAPL", "aapl", "aApL", "ａａｐｌ", "ＡＡＰＬ", "ＡaｐL"]
        let berkshireA = ["BRK-A", "BRK.A", "BRKA"]
        let berkshireB = ["BRK-B", "BRK.B", "BRKB"]

        var results: [String: Stock?] = [:]
        try await withThrowingTaskGroup(of: (String, Stock?).self) { group in
            (nilExpected + AAPLCaseVariations + berkshireA + berkshireB)
                .forEach { symbol in
                    let useCase = self.useCase!
                    group.addTask {
                        try (symbol, await useCase.execute(with: symbol))
                    }
                }
            for try await (symbol, stock) in group {
                results[symbol] = stock
            }
        }

        nilExpected.forEach {
            XCTAssertNil(results[$0]!)
        }

        AAPLCaseVariations.forEach {
            XCTAssertNotNil(results[$0]!)
            XCTAssertEqual(results[$0]!!.symbol, "AAPL")
            XCTAssertEqual(results[$0]!!.amount, 0)
            XCTAssertEqual(results[$0]!!.percentChanges.values.count, 4)
            XCTAssertNotNil(results[$0]!!.logoData)
            XCTAssertFalse(results[$0]!!.isETF)
            XCTAssertTrue(results[$0]!!.isActivelyTrading)
        }

        berkshireA.forEach {
            XCTAssertNotNil(results[$0]!)
            XCTAssertEqual(results[$0]!!.symbol, "BRK-A")
            XCTAssertTrue(results[$0]!!.isActivelyTrading)
        }

        berkshireB.forEach {
            XCTAssertNotNil(results[$0]!)
            XCTAssertEqual(results[$0]!!.symbol, "BRK-B")
            XCTAssertTrue(results[$0]!!.isActivelyTrading)
        }
    }
}
