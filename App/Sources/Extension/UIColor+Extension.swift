import UIKit

extension UIColor {
    static func byPercentChange(_ value: Double, period: Period) -> UIColor {
        let divisionFactor = period.colorPercentChangeThreshold() / Double(greenColors.count - 1)
        let index = Int(floor(fabs(value) / divisionFactor))
        let clampedIndex = min(max(index, 0), greenColors.count - 1)
        return value < 0 ? redColors[clampedIndex] : greenColors[clampedIndex]
    }

    static func byUpOrDown(_ value: Double) -> UIColor {
        value < 0 ? redColors.last! : greenColors.last!
    }

    static let legendColors: [UIColor] = [
        redColors[6], redColors[3], redColors[0], greenColors[0], greenColors[3], greenColors[6],
    ]

    static let redColors: [UIColor] = [
        .init(red: 65 / 255, green: 55 / 255, blue: 77 / 255, alpha: 1),
        .init(red: 93 / 255, green: 49 / 255, blue: 79 / 255, alpha: 1),
        .init(red: 120 / 255, green: 43 / 255, blue: 82 / 255, alpha: 1),
        .init(red: 147 / 255, green: 38 / 255, blue: 84 / 255, alpha: 1),
        .init(red: 174 / 255, green: 32 / 255, blue: 87 / 255, alpha: 1),
        .init(red: 202 / 255, green: 26 / 255, blue: 89 / 255, alpha: 1),
        .init(red: 229 / 255, green: 20 / 255, blue: 92 / 255, alpha: 1),
    ]

    static let greenColors: [UIColor] = [
        .init(red: 33 / 255, green: 82 / 255, blue: 81 / 255, alpha: 1),
        .init(red: 27 / 255, green: 102 / 255, blue: 88 / 255, alpha: 1),
        .init(red: 22 / 255, green: 123 / 255, blue: 95 / 255, alpha: 1),
        .init(red: 16 / 255, green: 144 / 255, blue: 103 / 255, alpha: 1),
        .init(red: 11 / 255, green: 165 / 255, blue: 110 / 255, alpha: 1),
        .init(red: 5 / 255, green: 185 / 255, blue: 117 / 255, alpha: 1),
        .init(red: 0 / 255, green: 206 / 255, blue: 124 / 255, alpha: 1),
    ]
}
