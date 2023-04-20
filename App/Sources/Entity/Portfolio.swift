import Foundation

struct Portfolio {
    var name: String
    var orderedSymbols: [String] = []
    var amounts: [String: Int] = [:]
    var key: String = ""
}
