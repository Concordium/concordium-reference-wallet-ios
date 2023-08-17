//
//  CIS2Service.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 10/08/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Combine
import Foundation

protocol CIS2ServiceProtocol {
    func fetchTokens(contractIndex: String, contractSubindex: String) -> AnyPublisher<CIS2Tokens, Error>
    func fetchTokensMetadata(contractIndex: String, contractSubindex: String, tokenId: String) -> AnyPublisher<CIS2TokensMetadata, Error>
    func fetchTokensMetadataURL(url: String) -> AnyPublisher<CIS2TokenDetails, Error>
}

class CIS2Service: CIS2ServiceProtocol {
    let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }

    func fetchTokens(contractIndex: String, contractSubindex: String = "0") -> AnyPublisher<CIS2Tokens, Error> {
        networkManager.load(
            ResourceRequest(url: ApiConstants.cis2Tokens.appendingPathComponent(contractIndex).appendingPathComponent(contractSubindex)
            )
        )
    }

    func fetchTokensMetadata(contractIndex: String, contractSubindex: String = "0", tokenId: String) -> AnyPublisher<CIS2TokensMetadata, Error> {
        let url = ApiConstants.cis2TokensMetadata.appendingPathComponent(contractIndex).appendingPathComponent(contractSubindex)
        let request = ResourceRequest(url: url, parameters: ["tokenId": tokenId])
        return networkManager.load(request)
    }

    func fetchTokensMetadataURL(url: String) -> AnyPublisher<CIS2TokenDetails, Error> {
        if let url = URL(string: url) {
            return networkManager.load(ResourceRequest(url: url))
        } else {
            return AnyPublisher<CIS2TokenDetails, Error>.fail(NetworkError.invalidRequest)
        }
    }
}
