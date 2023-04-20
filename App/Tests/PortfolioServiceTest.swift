@testable import Fintone
import XCTest

final class PortfolioServiceTest: XCTestCase {
    var service: PortfolioServiceProtocol!

    func testPortfolioServiceWithPortfolioService() async {
        service = PortfolioService()
        await service.reset()
        await testAllMethods()
    }

    func testPortfolioServiceWithInMemoryPortfolioService() async {
        service = InMemoryPortfolioService()
        await service.reset()
        await testAllMethods()
    }

    private func testAllMethods() async {
        // test setInitialPortfolio, getPortfolio
        _ = await service.setInitialPortfolio()
        let portfolio = await service.getPortfolio(key: "initialPortfolio")
        XCTAssertNotNil(portfolio)
        XCTAssertEqual(portfolio!.key, "initialPortfolio")

        // test addPortfolio, getPortfolios
        await service.addPortfolio(name: "セカンドポートフォリオ")
        var portfolios = await service.getPortfolios()
        XCTAssertEqual(portfolios.count, 2)
        var secondPortfolio = portfolios[1]
        XCTAssertEqual(secondPortfolio.name, "セカンドポートフォリオ")
        XCTAssertEqual(secondPortfolio.amounts, [:])
        XCTAssertEqual(secondPortfolio.orderedSymbols, [])

        // test updatePortfolio
        secondPortfolio.name = "変更します"
        await service.updatePortfolio(secondPortfolio)
        let newPortfolio = await service.getPortfolio(key: secondPortfolio.key)
        XCTAssertNotNil(newPortfolio)
        XCTAssertEqual(newPortfolio!.name, "変更します")

        // test getPortfolioKeys, savePortfolioKeys
        var keys = await service.getPortfolioKeys()
        XCTAssertEqual(keys.count, 2)
        XCTAssertEqual(keys.first!, "initialPortfolio")
        await service.savePortfolioKeys(keys: keys.reversed())
        let name = await service.getPortfolioKeys().last!
        XCTAssertEqual(name, "initialPortfolio")

        // test deletePortfolio
        await service.deletePortfolio(key: "initialPortfolio")
        let count = await service.getPortfolios().count
        XCTAssertEqual(count, 1)

        // test reset
        await service.reset()
        portfolios = await service.getPortfolios()
        keys = await service.getPortfolioKeys()
        XCTAssertTrue(portfolios.isEmpty)
        XCTAssertTrue(keys.isEmpty)
    }
}
