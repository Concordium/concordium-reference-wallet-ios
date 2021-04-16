import Foundation
import Combine

protocol NetworkManagerProtocol {
    func load<T: Decodable>(_ resource: URLRequest) -> AnyPublisher<T, Error>
    func load<T: Decodable>(_ resource: ResourceRequest) -> AnyPublisher<T, Error>
}

/// Defines the Network service errors.
enum NetworkError: Error {
    case invalidRequest
    case communicationError(error: Error)
    case invalidResponse
    case dataLoadingError(statusCode: Int, data: Data)
    case serverError(error: ServerErrorMessage)
    case jsonDecodingError(error: Error)
    case timeOut
}
