import Foundation

final class APIService {
    private let apiKey: String
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    private let baseURL: URL = .init(string: "https://financialmodelingprep.com")!

    init(apiKey: String) {
        assert(!apiKey.isEmpty, "APIKeyが空です")
        self.apiKey = apiKey
    }

    private enum Endpoint {
        case profile(String)
        case quote(String)
        case stockPriceChange(String)
        case historical

        var path: String {
            switch self {
            case let .profile(query):
                return "/api/v3/profile/\(query)"
            case let .quote(query):
                return "/api/v3/quote/\(query)"
            case let .stockPriceChange(query):
                return "/api/v3/stock-price-change/\(query)"
            case .historical:
                return "/api/v3/historical-chart/15min/^GSPC"
            }
        }
    }

    private func makeRequest(endpoint: Endpoint) throws -> URLRequest {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        components.path = endpoint.path
        components.queryItems = [.init(name: "apikey", value: apiKey)]
        guard let url = components.url else {
            throw APIServiceError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func downloadData(from url: URL) async throws -> Data {
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            log(error: error, requestUrl: url)
            throw APIServiceError.networkError
        }
        if let httpResponse = response as? HTTPURLResponse,
           !(200 ... 299).contains(httpResponse.statusCode)
        {
            log(response: response, requestUrl: url)
            throw APIServiceError.responseError(code: httpResponse.statusCode)
        }
        return data
    }

    private func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            log(error: error, requestUrl: request.url)
            throw APIServiceError.networkError
        }
        if let httpResponse = response as? HTTPURLResponse,
           !(200 ... 299).contains(httpResponse.statusCode)
        {
            log(response: response, requestUrl: request.url)
            throw APIServiceError.responseError(code: httpResponse.statusCode)
        }
        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            log(error: error, response: response, requestUrl: request.url)
            throw APIServiceError.decodingError
        }
    }
}

extension APIService: APIServiceProtocol {
    func fetchLatestOpeningDate() async throws -> Date? {
        let request = try makeRequest(endpoint: .historical)
        let historical: [Historical] = try await send(request)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter.date(from: historical[0].date)
    }

    func fetchExchangeRate() async throws -> Double {
        let quote = try await fetchQuotes(forSymbols: ["USDJPY"])
        return quote[0].price
    }

    func fetchProfiles(forSymbols symbols: [String]) async throws -> [Profile] {
        let query = symbols.joined(separator: ",")
        let request = try makeRequest(endpoint: .profile(query))
        return try await send(request)
    }

    func fetchQuotes(forSymbols symbols: [String]) async throws -> [Quote] {
        let query = symbols.joined(separator: ",")
        let request = try makeRequest(endpoint: .quote(query))
        return try await send(request)
    }

    func fetchStockPriceChanges(forSymbols symbols: [String]) async throws -> [StockPriceChange] {
        let query = symbols.joined(separator: ",")
        let request = try makeRequest(endpoint: .stockPriceChange(query))
        return try await send(request)
    }

    func fetchStocks(for portfolio: Portfolio) async throws -> [Stock] {
        let symbols = portfolio.orderedSymbols
        guard !symbols.isEmpty else { return .init([]) }
        async let profilesData = fetchProfiles(forSymbols: symbols)
        async let priceChangesData = fetchStockPriceChanges(forSymbols: symbols)
        let (profiles, priceChanges) = try await (profilesData, priceChangesData)
        let logos = try await downloadLogoData(from: profiles)
        return symbols.compactMap { symbol -> Stock? in
            guard let profile = profiles.first(where: { $0.symbol == symbol }) else { return nil }
            return Stock(
                profile: profile,
                stockPriceChange: priceChanges.first(where: { $0.symbol == symbol }),
                amount: portfolio.amounts[symbol] ?? 0,
                logoData: logos[symbol] ?? nil
            )
        }
    }

    func fetchIndices() async throws -> [Index] {
        let symbols = ["^DJI", "^GSPC", "^IXIC"]
        async let asyncQuotes = fetchQuotes(forSymbols: symbols)
        async let asyncPriceChanges = fetchStockPriceChanges(forSymbols: symbols)
        let (quotes, priceChanges) = try await (asyncQuotes, asyncPriceChanges)
        return zip(symbols, ["DOW30", "S&P500", "Nasdaq"]).compactMap { symbol, name -> Index? in
            guard let quote = quotes.first(where: { $0.symbol == symbol }),
                  let priceChange = priceChanges.first(where: { $0.symbol == symbol })
            else { return nil }
            return Index(quote: quote, stockPriceChange: priceChange, name: name)
        }
    }

    func downloadLogoData(from profiles: [Profile]) async throws -> [String: Data?] {
        try await withThrowingTaskGroup(of: (String, Data?).self) { group in
            profiles
                .compactMap { profile -> (String, URL)? in
                    guard let url = profile.image else { return nil }
                    return (profile.symbol, url)
                }
                .forEach { symbol, url in
                    group.addTask {
                        do {
                            return (symbol, try await self.downloadData(from: url))
                        } catch {
                            return (symbol, nil)
                        }
                    }
                }
            var logos: [String: Data] = [:]
            for try await (symbol, data) in group {
                logos[symbol] = data
            }
            return logos
        }
    }
}

extension APIService {
    private func log(error: Error? = nil, response: URLResponse? = nil, requestUrl: URL?) {
        var message = """
        ---------------------
        Request: \(requestUrl?.description ?? "nil")

        """
        if let httpResponse = response as? HTTPURLResponse {
            message += """
            Status code: \(httpResponse.statusCode)

            """
        }
        if let error = error {
            message += """
            Error: \(error.localizedDescription)
            Stack trace: \(error)

            """
        }
        message += "---------------------"

        print(message)
    }
}

private extension Index {
    init(quote: Quote, stockPriceChange: StockPriceChange, name: String) {
        self.init(
            symbol: quote.symbol,
            name: name,
            currentPrice: quote.price,
            percentChanges:
            PercentChanges(values: [
                .daily: stockPriceChange.daily,
                .weekly: stockPriceChange.weekly,
                .monthly: stockPriceChange.monthly,
                .yearToDate: stockPriceChange.ytd,
            ])
        )
    }
}

private extension Stock {
    init(profile: Profile, stockPriceChange: StockPriceChange?, amount: Int, logoData: Data?) {
        var profile = profile
        var stockPriceChange = stockPriceChange
        if !profile.isActivelyTrading {
            profile.price = nil
            stockPriceChange = nil
        }
        self.init(
            amount: amount,
            symbol: profile.symbol,
            name: profile.companyName,
            logoData: logoData,
            currentPrice: profile.price ?? 0,
            percentChanges: PercentChanges(values: [
                .daily: stockPriceChange?.daily ?? 0,
                .weekly: stockPriceChange?.weekly ?? 0,
                .monthly: stockPriceChange?.monthly ?? 0,
                .yearToDate: stockPriceChange?.ytd ?? 0,
            ]),
            isETF: profile.isEtf,
            isActivelyTrading: profile.isActivelyTrading
        )
    }
}
