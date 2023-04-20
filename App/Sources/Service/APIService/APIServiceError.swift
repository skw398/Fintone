import Foundation

enum APIServiceError: LocalizedError {
    case invalidURL
    case networkError
    case responseError(code: Int)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return R.string.localizable.invalidRequest()
        case .networkError:
            return R.string.localizable.networkErrorOccurred()
        case let .responseError(code):
            return R.string.localizable.fetchErrorOccurred() + "(\(code))"
        case .decodingError:
            return R.string.localizable.decodeErrorOccurred()
        }
    }
}
