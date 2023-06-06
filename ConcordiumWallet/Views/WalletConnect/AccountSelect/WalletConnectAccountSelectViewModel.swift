//
//  WalletConnectAccountSelectViewModel.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 06/06/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import SwiftUI
import WalletConnectSign

class WalletConnectAccountSelectViewModel: ObservableObject {
    private var storageManager: StorageManagerProtocol
    @Published var accounts: [AccountDataType] = []
    private var proposal: Session.Proposal
    // walletConnectClient
    init(storageManager: StorageManagerProtocol, proposal: Session.Proposal) {
        self.proposal = proposal
        self.storageManager = storageManager
    }
    
    func getAccounts() {
        accounts = storageManager.getAccounts()
    }
    
    func didSelect(accountAddress: String) {
        Task {
            do {
                let blockchain = Blockchain("ccd:testnet")!
                let sessionNamespaces = try AutoNamespaces.build(
                    sessionProposal: proposal,
                    chains: [blockchain], // TODO: Use Genesis hash here before hitting production
                    methods: ["eth_sendTransaction", "personal_sign"],
                    events: ["accountsChanged", "chainChanged"],
                    accounts: [
                        Account(blockchain: blockchain, address:"ccd:\(accountAddress)")!
                    ]
                )
                try await Sign.instance.approve(proposalId: proposal.id, namespaces: sessionNamespaces)
            } catch {
                print(error)
            }
        }
    }
}