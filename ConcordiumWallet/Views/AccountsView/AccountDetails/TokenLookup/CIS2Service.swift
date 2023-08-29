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
    func fetchTokens(contractIndex: String, contractSubindex: String) -> AnyPublisher<CIS2TokensInfo, Error>
    func fetchTokensMetadata(contractIndex: String, contractSubindex: String, tokenId: String) -> AnyPublisher<CIS2TokensMetadata, Error>
    func fetchTokensMetadataDetails(url: String) -> AnyPublisher<CIS2TokenMetadataDetails, Error>
    func fetchTokensBalance(contractIndex: String, contractSubindex: String, accountAddress: String, tokenId: String) -> AnyPublisher<[CIS2TokenBalance], Error>
    func getUserStoredCIS2Tokens(accountAddress: String, contractIndex: String) -> [CIS2TokenSelectionRepresentable]
    func storeCIS2Tokens(_ tokens: [CIS2TokenSelectionRepresentable], accountAddress: String) throws
}

class CIS2Service: CIS2ServiceProtocol {
    let networkManager: NetworkManagerProtocol
    let storageManager: StorageManagerProtocol
    init(networkManager: NetworkManagerProtocol, storageManager: StorageManagerProtocol) {
        self.networkManager = networkManager
        self.storageManager = storageManager
    }

    func getUserStoredCIS2Tokens(accountAddress: String, contractIndex: String) -> [CIS2TokenSelectionRepresentable] {
        storageManager.getUserStoredCIS2Tokens(accountAddress: accountAddress, contractIndex: contractIndex).map {
            CIS2TokenSelectionRepresentable(
                tokenId: $0.tokenId,
                balance: $0.balance,
                contractIndex: $0.contractIndex,
                name: $0.name,
                symbol: $0.symbol,
                decimals: $0.decimals,
                description: $0.tokenDescription,
                thumbnail: URL(string: $0.thumbnail ?? "") ?? nil,
                unique: $0.unique,
                accountAddress: $0.accountAddress)
        }
    }
    
    func storeCIS2Tokens(_ tokens: [CIS2TokenSelectionRepresentable], accountAddress: String) throws {
       try storageManager.storeCIS2Tokens(tokens, accountAddress: accountAddress)
    }

    func fetchTokens(contractIndex: String, contractSubindex: String = "0") -> AnyPublisher<CIS2TokensInfo, Error> {
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

    func fetchTokensMetadataDetails(url: String) -> AnyPublisher<CIS2TokenMetadataDetails, Error> {
        if let url = URL(string: url) {

                return networkManager.load(ResourceRequest(url: url))
                    .tryMap { (metadata: CIS2TokenMetadataDetails) in
                        try self.storageManager.storeCIS2TokenMetadataDetails(metadata, for: url.absoluteString)
                        return metadata
                    }
                    .eraseToAnyPublisher()
        } else {
            return AnyPublisher<CIS2TokenMetadataDetails, Error>.fail(NetworkError.invalidRequest)
        }
    }

    func fetchTokensBalance(contractIndex: String, contractSubindex: String = "0", accountAddress: String, tokenId: String) -> AnyPublisher<[CIS2TokenBalance], Error> {
        networkManager.load(
            ResourceRequest(url:
                ApiConstants.cis2TokenBalance
                    .appendingPathComponent(contractIndex)
                    .appendingPathComponent(contractSubindex)
                    .appendingPathComponent(accountAddress),
                parameters: ["tokenId": tokenId]
            )
        )
    }
}
