import Foundation

struct ServiceDependencies {
    static var apiService: APIServiceProtocol { services.apiService }
    static var portfolioService: PortfolioServiceProtocol { services.portfolioService }

    private static let services: (apiService: APIServiceProtocol, portfolioService: PortfolioServiceProtocol) = {
        if let apiKeyClass = NSClassFromString("Fintone.APIKey") as? APIKeyProtocol.Type {
            return (APIService(apiKey: apiKeyClass.key), PortfolioService())
        } else {
            #if DEBUG
                return (MockAPIService(), InMemoryPortfolioService())
            #else
                fatalError("APIKeyが見つかりません")
            #endif
        }
    }()
}
