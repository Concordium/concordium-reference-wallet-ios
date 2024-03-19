//
//  SearchTokenViewModel.swift
//  ConcordiumWallet
//
//  Created by Maksym Rachytskyy on 19.03.2024.
//  Copyright © 2024 concordium. All rights reserved.
//

import Foundation
import BigInt

final class SearchTokenViewModel: ObservableObject {
    @Published var tokens: [CIS2TokenSelectionRepresentable] = []
    @Published var isSearching: Bool = false
    
    private let service: CIS2ServiceProtocol
    private let accountAddress: String
    private let contractIndex: String
    
    init(
        accountAdress: String,
        contractIndex: String,
        service: CIS2ServiceProtocol
    ){
        self.service = service
        self.accountAddress = accountAdress
        self.contractIndex = contractIndex
    }
    
    func runSearch(_ tokenIndex: String) {
        isSearching = true
        Task {
            do {
                let data = try await searchTokenData(by: tokenIndex)
                await MainActor.run {
                    tokens = data
                    isSearching = false
                }
            } catch {
                await MainActor.run {
                    isSearching = false
                }
            }
        }
    }
    
    func searchTokenData(by tokenId: String) async throws -> [CIS2TokenSelectionRepresentable] {
        let metadata = try await service.fetchTokensMetadata(contractIndex: contractIndex, contractSubindex: "0", tokenId: tokenId)
        let metadataPairs = try await service.getTokenMetadataPair(metadata: metadata)
        let balances = try await service.fetchTokensBalance(contractIndex: contractIndex, contractSubindex: "0", accountAddress: accountAddress, tokenId: tokenId)
        
        return metadataPairs.map { (metadataItem, details) in
            CIS2TokenSelectionRepresentable(
                contractName: metadata.contractName,
                tokenId: metadataItem.tokenId,
                balance: BigInt(balances.first(where: { $0.tokenId == metadataItem.tokenId })?.balance ?? "") ?? .zero,
                contractIndex: contractIndex,
                name: details.name,
                symbol: details.symbol,
                decimals: details.decimals ?? 6,
                description: details.description,
                thumbnail: details.thumbnail?.url,
                display: details.display?.url,
                unique: details.unique ?? false,
                accountAddress: accountAddress)
        }
    }
}
