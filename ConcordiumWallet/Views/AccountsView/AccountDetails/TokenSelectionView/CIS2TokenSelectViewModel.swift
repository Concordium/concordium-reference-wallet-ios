//
//  CIS2TokenSelectViewModel.swift
//  ConcordiumWallet
//
//  Created by Maksym Rachytskyy on 04.03.2024.
//  Copyright © 2024 concordium. All rights reserved.
//

import Foundation
import BigInt

final class CIS2TokenSelectViewModel: ObservableObject {
    @Published var tokens: [CIS2TokenSelectionRepresentable] = []
    @Published var isLoading: Bool = false
    @Published var hasMore: Bool = true
    @Published var currentPage = 1
    
    private let allContractTokens: [CIS2Token]
    private let batchSize: Int
    private let service: CIS2ServiceProtocol
    private let accountAddress: String
    private let contractIndex: String
    
    init(
        allContractTokens: [CIS2Token],
        accountAdress: String,
        contractIndex: String,
        service: CIS2ServiceProtocol,
        batchSize: Int = 20
    ){
        self.allContractTokens = allContractTokens
        self.batchSize = batchSize
        self.service = service
        self.accountAddress = accountAdress
        self.contractIndex = contractIndex
    }
    
    func loadInitial() {
        tokens = []
        currentPage = 1
        hasMore = true
        isLoading = false
        loadMore()
    }
    
    func loadMore() {
        guard !isLoading, hasMore else { return }

        isLoading = true
        
        Task {
            do {
                let ids = allContractTokens.dropFirst((currentPage - 1) * batchSize).prefix(batchSize)
                
                guard !ids.isEmpty else {
                    return await MainActor.run {
                        hasMore = false
                        isLoading = false
                    }
                }
                
                let metadata = try await service.fetchTokensMetadata(contractIndex: contractIndex, contractSubindex: "0", tokenId: ids.map { $0.token }.joined(separator: ","))
                let metadataPairs = try await service.getTokenMetadataPair(metadata: metadata)
                let balances = try await service.fetchTokensBalance(contractIndex: contractIndex, contractSubindex: "0", accountAddress: accountAddress, tokenId: ids.map { $0.token }.joined(separator: ","))
                
                let representables = metadataPairs.map { (metadataItem, details) in
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
                
                await MainActor.run {
                    hasMore = !metadata.metadata.isEmpty
                    
                    if currentPage == 1 {
                        tokens = representables
                    } else {
                        tokens += representables
                    }
                    currentPage += 1
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}
