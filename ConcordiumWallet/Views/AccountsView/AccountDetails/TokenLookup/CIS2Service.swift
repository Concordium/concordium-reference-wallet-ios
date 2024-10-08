//
//  CIS2Service.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 10/08/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import BigInt
import Combine
import Foundation
import CryptoKit

protocol CIS2ServiceProtocol {
    func fetchTokens(contractIndex: String, contractSubindex: String) -> AnyPublisher<CIS2TokensInfo, Error>
    func fetchTokensMetadata(contractIndex: String, contractSubindex: String, tokenId: String) -> AnyPublisher<CIS2TokensMetadata, Error>
    func fetchTokensMetadataDetails(url: String) -> AnyPublisher<CIS2TokenMetadataDetails, Error>
    func fetchTokensBalance(contractIndex: String, contractSubindex: String, accountAddress: String, tokenId: String) -> AnyPublisher<[CIS2TokenBalance], Error>


    func observedTokensPublisher(for accountAddress: String) -> AnyPublisher<[CIS2TokenSelectionRepresentable], Error>
    func observedTokensPublisher(for accountAddress: String, filteredBy contractIndex: String) -> AnyPublisher<[CIS2TokenSelectionRepresentable], Error>
    func observedTokens(for accountAddress: String, filteredBy contractIndex: String) -> [CIS2TokenSelectionRepresentable]
    
    func storeCIS2Tokens(_ tokens: [CIS2TokenSelectionRepresentable], accountAddress: String, contractIndex: String) throws
    func fetchTokensMetadata(contractIndex: String, contractSubindex: String, tokenId: String) async throws -> CIS2TokensMetadata
    func fetchTokensBalance(contractIndex: String, contractSubindex: String, accountAddress: String, tokenId: String) async throws -> [CIS2TokenBalance]
    func deleteTokenFromCache(_ token: CIS2TokenSelectionRepresentable) throws
    func fetchTokensMetadataDetails(url: URL, metadataChecksum: String?) async throws -> CIS2TokenMetadataDetails
    
    func getTokenMetadataPair(metadata: CIS2TokensMetadata) async throws -> [(CIS2TokensMetadataItem, CIS2TokenMetadataDetails)]
}

enum ChecksumError: Error {
    case invalidChecksum
    case incorrectChecksum
}

class CIS2Service: CIS2ServiceProtocol {
    let networkManager: NetworkManagerProtocol
    let storageManager: StorageManagerProtocol

    init(networkManager: NetworkManagerProtocol, storageManager: StorageManagerProtocol) {
        self.networkManager = networkManager
        self.storageManager = storageManager
    }

    func observedTokensPublisher(for accountAddress: String, filteredBy contractIndex: String) -> AnyPublisher<[CIS2TokenSelectionRepresentable], Error> {
        observedTokensPublisher(for: accountAddress)
            .map { $0.filter { $0.contractIndex == contractIndex } }
            .eraseToAnyPublisher()
    }

    func observedTokens(for accountAddress: String, filteredBy contractIndex: String) -> [CIS2TokenSelectionRepresentable] {
        storageManager.getUserStoredCIS2Tokens(for: accountAddress, filteredBy: contractIndex).map {
            transformCIS2Token(from: $0)
        }
    }

    func observedTokensPublisher(for accountAddress: String) -> AnyPublisher<[CIS2TokenSelectionRepresentable], Error> {
        storageManager.getCIS2TokensPublisher(for: accountAddress)
            .map {
                Publishers.MergeMany(
                    $0.map { entity in
                        self.fetchTokensBalance(
                            contractIndex: entity.contractIndex,
                            contractSubindex: "0",
                            accountAddress: entity.accountAddress,
                            tokenId: entity.tokenId
                        )
                        .compactMap { $0.first }
                        .tryMap {
                            guard let balance = BigInt($0.balance) else { throw TokenError.inputError(msg: "Invalid token balance.") }
                            return CIS2TokenSelectionRepresentable(entity: entity, tokenBalance: balance)
                        }
                    }
                )
                .collect()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    private func transformCIS2Token(from entity: CIS2TokenOwnershipEntity) -> CIS2TokenSelectionRepresentable {
        CIS2TokenSelectionRepresentable(
            contractName: entity.contractName,
            tokenId: entity.tokenId,
            balance: .zero,
            contractIndex: entity.contractIndex,
            name: entity.name,
            symbol: entity.symbol,
            decimals: entity.decimals,
            description: entity.tokenDescription,
            thumbnail: URL(string: entity.thumbnail ?? "") ?? nil, 
            display: URL(string: entity.display ?? "") ?? nil,
            unique: entity.unique,
            accountAddress: entity.accountAddress
        )
    }

    func storeCIS2Tokens(_ tokens: [CIS2TokenSelectionRepresentable], accountAddress: String, contractIndex: String) throws {
        try storageManager.storeCIS2Tokens(tokens, accountAddress: accountAddress, contractIndex: contractIndex)
    }

    func deleteTokenFromCache(_ token: CIS2TokenSelectionRepresentable) throws {
        try storageManager.deleteCIS2Token(token)
    }

    func fetchTokens(contractIndex: String, contractSubindex: String = "0") -> AnyPublisher<CIS2TokensInfo, Error> {
        networkManager.load(
            ResourceRequest(
                url: ApiConstants.cis2Tokens
                    .appendingPathComponent(contractIndex)
                    .appendingPathComponent(contractSubindex),
                parameters: ["limit" : "1000"]
            )
        )
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
                ApiConstants.cis2TokenBalanceV1
                    .appendingPathComponent(contractIndex)
                    .appendingPathComponent(contractSubindex)
                    .appendingPathComponent(accountAddress),
                parameters: ["tokenId": tokenId]
            )
        )
    }
}

extension CIS2Service {
    /// Fetches metadata for tokens specified by their identifiers within a contract.
    ///
    /// - Parameters:
    ///   - contractIndex: The index of the contract to fetch token metadata from.
    ///   - contractSubindex: The subindex of the contract. Defaults to "0" if not provided.
    ///   - tokenIds: An string of comma separated string identifiers representing the tokens for which metadata is to be fetched.
    ///   - API: `GET /v1/CIS2Tokens/{index}/{subindex}`
    ///
    func fetchTokensMetadata(contractIndex: String, contractSubindex: String = "0", tokenId: String) -> AnyPublisher<CIS2TokensMetadata, Error> {
        let url = ApiConstants.cis2TokensMetadataV1.appendingPathComponent(contractIndex).appendingPathComponent(contractSubindex)
        let request = ResourceRequest(url: url, parameters: ["tokenId": tokenId])
        return networkManager.load(request)
    }
}

enum AsyncError: Error {
    case finishedWithoutValue
}


extension CIS2Service {
    func fetchTokens(contractIndex: String, contractSubindex: String = "0") async throws -> CIS2TokensInfo {
        try await networkManager.load(
            ResourceRequest(
                url: ApiConstants.cis2Tokens
                    .appendingPathComponent(contractIndex)
                    .appendingPathComponent(contractSubindex),
                parameters: ["limit" : "1000"]
            )
        )
    }
    
    func fetchTokensMetadata(contractIndex: String, contractSubindex: String = "0", tokenId: String) async throws -> CIS2TokensMetadata {
        let url = ApiConstants.cis2TokensMetadataV1.appendingPathComponent(contractIndex).appendingPathComponent(contractSubindex)
        let request = ResourceRequest(url: url, parameters: ["tokenId": tokenId])
        return try await  networkManager.load(request)
    }
    
    func fetchTokensBalance(contractIndex: String, contractSubindex: String = "0", accountAddress: String, tokenId: String) async throws -> [CIS2TokenBalance] {
        try await networkManager.load(
            ResourceRequest(url:
                ApiConstants.cis2TokenBalanceV1
                    .appendingPathComponent(contractIndex)
                    .appendingPathComponent(contractSubindex)
                    .appendingPathComponent(accountAddress),
                parameters: ["tokenId": tokenId]
            )
        )
    }
    
    func fetchTokensMetadataDetails(url: URL, metadataChecksum: String?) async throws -> CIS2TokenMetadataDetails {
        let metadata: CIS2TokenMetadataDetails = try await networkManager.load(ResourceRequest(url: url))
        
        if let metadataChecksum {
            try await verifyChecksum(checksum: metadataChecksum, url: url)
        }
        
        try await MainActor.run {
            try self.storageManager.storeCIS2TokenMetadataDetails(metadata, for: url.absoluteString)
        }

        return metadata
    }
}

extension CIS2Service {
    /// Retrieves a pair of metadata items and their corresponding token metadata details.
    ///
    /// This function asynchronously retrieves pairs of metadata items and their corresponding token metadata details from the provided `CIS2TokensMetadata`.
    /// It utilizes the `fetchTokensMetadataDetails` method of the `service` object to fetch token metadata details for each metadata item's URL.
    ///  If a metadata item's URL is invalid or fetching the details fails, the entire item will be skipped in the result.
    ///
    /// - Parameter metadata: The `CIS2TokensMetadata` containing the metadata items.
    ///
    /// - Returns: An array of tuples, each containing a `CIS2TokensMetadataItem` and its corresponding `CIS2TokenMetadataDetails`.
    ///
    func getTokenMetadataPair(metadata: CIS2TokensMetadata) async throws -> [(CIS2TokensMetadataItem, CIS2TokenMetadataDetails)] {
        try await withThrowingTaskGroup(of: (CIS2TokensMetadataItem, CIS2TokenMetadataDetails)?.self) { [weak self] group in
            guard let self else { return [] }
            for metadata in metadata.metadata {
                if let url = URL(string: metadata.metadataURL) {
                    group.addTask {
                        guard let result = try? await self.fetchTokensMetadataDetails(url: url, metadataChecksum: metadata.metadataChecksum) else {
                            return nil
                        }
                        return (metadata, result)
                    }
                }
            }
            
            return try await group
                .compactMap { $0 }
                .reduce(into: []) { $0.append($1) }
        }
    }
    
    /// Verifies the checksum of the response data against a provided checksum.
    ///
    /// - Parameters:
    ///   - checksum: The expected checksum.
    ///   - responseData: The data to verify.
    /// - Throws: `ChecksumError.incorrectChecksum` if the checksums do not match.
    func verifyChecksum(checksum: String, url: URL) async throws {
        let (data, _) = try await URLSession(configuration: .ephemeral).data(from: url)
        let hash = SHA256.hash(data: data)
        let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
        guard hashString.localizedCaseInsensitiveCompare(checksum) == .orderedSame else {
            throw ChecksumError.incorrectChecksum
        }
    }
}
