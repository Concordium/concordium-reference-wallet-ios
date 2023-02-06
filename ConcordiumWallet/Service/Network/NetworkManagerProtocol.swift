import Foundation
import Combine

protocol NetworkManagerProtocol {
    func load<T: Decodable>(_ resource: URLRequest) -> AnyPublisher<T, Error>
    func load<T: Decodable>(_ resource: ResourceRequest) -> AnyPublisher<T, Error>
    func load<T: Decodable>(_ resource: URLRequest) async throws -> T
    func loadRecovery<T: Decodable>(_ resource: URLRequest) async throws -> T
    func load<T: Decodable>(_ resource: ResourceRequest) async throws -> T
    func loadRecovery<T: Decodable>(_ resource: ResourceRequest) async throws -> T
}

extension NetworkManagerProtocol {
    func load<T: Decodable>(_ resource: ResourceRequest) -> AnyPublisher<T, Error> {
        guard let request = resource.request else {
            return Fail(error: NetworkError.invalidRequest).eraseToAnyPublisher()
        }
        return load(request)
    }
    
    func load<T: Decodable>(_ resource: ResourceRequest) async throws -> T {
        guard let request = resource.request else {
            throw NetworkError.invalidRequest
        }
        return try await load(request)
    }
    
    func loadRecovery<T: Decodable>(_ resource: ResourceRequest) async throws -> T {
        guard let request = resource.request else {
            throw NetworkError.invalidRequest
        }
        return try await loadRecovery(request)
    }
    
    func load<T: Decodable>(
        _ resource: URLRequest,
        decoding type: T.Type
    ) -> AnyPublisher<T, Error> {
        return load(resource)
    }
    
    func load<T: Decodable>(
        _ resource: ResourceRequest,
        decoding type: T.Type
    ) -> AnyPublisher<T, Error> {
        return load(resource)
    }
    
    func load<T: Decodable>(
        _ resource: URLRequest,
        decoding type: T.Type
    ) async throws -> T {
        return try await load(resource)
    }
    
    func load<T: Decodable>(
        _ resource: ResourceRequest,
        decoding type: T.Type
    ) async throws -> T {
        return try await load(resource)
    }
    
    func loadRecovery<T: Decodable>(
        _ resource: ResourceRequest,
        decoding type: T.Type
    ) async throws -> T {
        return try await loadRecovery(resource)
    }
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
