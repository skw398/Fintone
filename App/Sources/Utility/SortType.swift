import Foundation

enum SortType: Int, CaseIterable {
    case customOrder, alphabetical, changePercent, marketValue, profitOrLoss

    var sortTypeName: String {
        switch self {
        case .customOrder:
            return R.string.localizable.customOrder()
        case .alphabetical:
            return R.string.localizable.alphabetical()
        case .changePercent:
            return R.string.localizable.percentChange()
        case .marketValue:
            return R.string.localizable.marketValue()
        case .profitOrLoss:
            return R.string.localizable.profitOrLoss()
        }
    }

    var iconImageName: String {
        switch self {
        case .customOrder:
            return "arrow.up.and.down.text.horizontal"
        case .alphabetical:
            return "abc"
        case .changePercent:
            return "percent"
        case .marketValue:
            return "dollarsign"
        case .profitOrLoss:
            return "plus.forwardslash.minus"
        }
    }
}
