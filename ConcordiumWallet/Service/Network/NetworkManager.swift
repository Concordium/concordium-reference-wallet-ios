//
// Created by Johan Rugager Vase on 13/02/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import Combine

protocol NetworkSession {
    func load(request: URLRequest) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure>
}

extension URLSession: NetworkSession {
    func load(request: URLRequest) -> AnyPublisher<DataTaskPublisher.Output, DataTaskPublisher.Failure> {
        dataTaskPublisher(for: request).eraseToAnyPublisher()
    }
}

final class NetworkManager: NetworkManagerProtocol {
    private let session: NetworkSession

    init(session: NetworkSession = URLSession(configuration: URLSessionConfiguration.ephemeral)) {
        self.session = session
    }

    func load<T: Decodable>(_ resource: ResourceRequest) -> AnyPublisher<T, Error> {
        guard let request = resource.request else {
            return Fail(error: NetworkError.invalidRequest).eraseToAnyPublisher()
        }
        return load(request)
    }
    func load<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        if Logger.shouldLog(on: .debug) {
            if let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
                Logger.debug("TX \(request.httpMethod) \(request.url):\n\(bodyString)")
            } else {
                Logger.debug("TX \(request.httpMethod) \(request)")
            }
        }
        return session.load(request: request)
                .mapError { err in
                    return NetworkError.communicationError(error: err) }
                .flatMap { data, response -> AnyPublisher<Data, Error> in
                    guard let response = response as? HTTPURLResponse else {
                        return .fail(NetworkError.invalidResponse)
                    }

                    guard 200..<300 ~= response.statusCode else {
                        Logger.error("RX \(response.statusCode) \(request.url):\n\(String(data: data, encoding: .utf8) ?? "")")
                        if let error = try? ServerErrorMessage(data: data) {
                            return .fail(NetworkError.serverError(error: error))
                        }
                        return .fail(NetworkError.dataLoadingError(statusCode: response.statusCode, data: data))
                    }
                    return .just(data)
                }
                .map { data in
                    Logger.debug("RX \(request.url):\n\(String(data: data, encoding: .utf8) ?? "")")
                    return data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .mapError({ error -> Error in
                    if error is NetworkError {
                        return error // do not attempt to map an error that is not caused by the json decoding
                    }
                    Logger.error("cannot decode - \(request.url):\n\(error)")
                    return NetworkError.jsonDecodingError(error: error)
                })
                .performInBackground()
                //comment this in to force loading indicator
//                .delay(for: 1.0, scheduler: RunLoop.main)
                .eraseToAnyPublisher()
    }
}
