//
//  CIS2Service.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 10/08/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Combine
import Foundation
import BigInt

protocol CIS2ServiceProtocol {
    func fetchTokens(contractIndex: String, contractSubindex: String) -> AnyPublisher<CIS2TokensInfo, Error>
    func fetchTokensMetadata(contractIndex: String, contractSubindex: String, tokenId: String) -> AnyPublisher<CIS2TokensMetadata, Error>
    func fetchTokensMetadataDetails(url: String) -> AnyPublisher<CIS2TokenMetadataDetails, Error>
    func fetchTokensBalance(contractIndex: String, contractSubindex: String, accountAddress: String, tokenId: String) -> AnyPublisher<[CIS2TokenBalance], Error>
    func storeCIS2Tokens(_ tokens: [CIS2TokenSelectionRepresentable], accountAddress: String, contractIndex: String) throws
    func getUserStoredCIS2Tokens(for accountAddress: String, in contractIndex: String) -> [CIS2TokenSelectionRepresentable]
    func getUserStoredCIS2Tokens(for accountAddress: String) -> [CIS2TokenSelectionRepresentable]
    func deleteTokenFromCache(_ token: CIS2TokenSelectionRepresentable) throws
    func observedTokensPublisher(for accountAddress: String) -> AnyPublisher<[CIS2TokenSelectionRepresentable], Error>
}

class CIS2Service: CIS2ServiceProtocol {
    let networkManager: NetworkManagerProtocol
    let storageManager: StorageManagerProtocol

    init(networkManager: NetworkManagerProtocol, storageManager: StorageManagerProtocol) {
        self.networkManager = networkManager
        self.storageManager = storageManager
    }

    func observedTokensPublisher(for accountAddress: String) -> AnyPublisher<[CIS2TokenSelectionRepresentable], Error> {
        storageManager.getCIS2TokensPublisher(for: accountAddress)
            .map {
                Publishers.MergeMany(
                    $0.map { token in
                        self.fetchTokensBalance(
                            contractIndex: token.contractIndex,
                            contractSubindex: "0",
                            accountAddress: token.accountAddress,
                            tokenId: token.tokenId
                        )
                        .compactMap { $0.first }
                        .map {
                            CIS2TokenSelectionRepresentable(
                                contractName: token.contractName,
                                tokenId: token.tokenId,
                                balance: BigInt($0.balance) ?? .zero,
                                contractIndex: token.contractIndex,
                                name: token.name,
                                symbol: token.symbol,
                                decimals: token.decimals,
                                description: token.tokenDescription,
                                thumbnail: URL(string: token.thumbnail ?? ""),
                                unique: token.unique,
                                accountAddress: token.accountAddress
                            )
                        }
                    }
                )
                .collect()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    func getUserStoredCIS2Tokens(for accountAddress: String, in contractIndex: String) -> [CIS2TokenSelectionRepresentable] {
        storageManager.getUserStoredCIS2Tokens(for: accountAddress, in: contractIndex).map {
            CIS2TokenSelectionRepresentable(
                contractName: $0.contractName,
                tokenId: $0.tokenId,
                balance: .zero,
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

    func getUserStoredCIS2Tokens(for accountAddress: String) -> [CIS2TokenSelectionRepresentable] {
        storageManager.getUserStoredCIS2Tokens(for: accountAddress).map {
            CIS2TokenSelectionRepresentable(
                contractName: $0.contractName,
                tokenId: $0.tokenId,
                balance: .zero,
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

    func storeCIS2Tokens(_ tokens: [CIS2TokenSelectionRepresentable], accountAddress: String, contractIndex: String) throws {
        try storageManager.storeCIS2Tokens(tokens, accountAddress: accountAddress, contractIndex: contractIndex)
    }

    func deleteTokenFromCache(_ token: CIS2TokenSelectionRepresentable) throws {
        try storageManager.deleteCIS2Token(token)
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
