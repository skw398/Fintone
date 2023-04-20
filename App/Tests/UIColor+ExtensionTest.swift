@testable import Fintone
import XCTest

final class UIColorExtensionTest: XCTestCase {
    func testColorByUpOrDown() throws {
        var color: UIColor

        color = .byUpOrDown(-1)
        XCTAssertEqual(color, .redColors.last!)
        color = .byUpOrDown(0)
        XCTAssertEqual(color, .greenColors.last!)
        color = .byUpOrDown(1)
        XCTAssertEqual(color, .greenColors.last!)
    }

    func testColorByPercentChange() throws {
        var color: UIColor

        color = .byPercentChange(-0.01, period: .daily)
        XCTAssertEqual(color, .redColors[0])
        color = .byPercentChange(-0.5, period: .daily)
        XCTAssertEqual(color, .redColors[1])
        color = .byPercentChange(-2.99, period: .daily)
        XCTAssertEqual(color, .redColors[5])
        color = .byPercentChange(-3, period: .daily)
        XCTAssertEqual(color, .redColors[6])
        color = .byPercentChange(-3.01, period: .daily)
        XCTAssertEqual(color, .redColors[6])
        color = .byPercentChange(-999, period: .daily)
        XCTAssertEqual(color, .redColors[6])

        color = .byPercentChange(0, period: .daily)
        XCTAssertEqual(color, .greenColors[0])
        color = .byPercentChange(0.01, period: .daily)
        XCTAssertEqual(color, .greenColors[0])
        color = .byPercentChange(0.5, period: .daily)
        XCTAssertEqual(color, .greenColors[1])
        color = .byPercentChange(2.99, period: .daily)
        XCTAssertEqual(color, .greenColors[5])
        color = .byPercentChange(3, period: .daily)
        XCTAssertEqual(color, .greenColors[6])
        color = .byPercentChange(999, period: .daily)
        XCTAssertEqual(color, .greenColors[6])
    }
}
