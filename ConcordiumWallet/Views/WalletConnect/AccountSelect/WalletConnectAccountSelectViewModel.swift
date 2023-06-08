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
    var didSelectAccount: ((_ address: String) -> ())? // TODO should be "accountName"
    // TODO: implement WalletConnectClient
    init(storageManager: StorageManagerProtocol, proposal: Session.Proposal) {
        self.proposal = proposal
        self.storageManager = storageManager
    }
    
    func getAccounts() {
        accounts = storageManager.getAccounts()
    }
    
    func didSelect(accountAddress: String) {
        didSelectAccount?(accountAddress)
//        Task {
//            do {
//                let blockchain = Blockchain("ccd:testnet")!
//                let sessionNamespaces = try AutoNamespaces.build(
//                    sessionProposal: proposal,
//                    chains: [blockchain], // TODO: Use Genesis hash here before hitting production
//                    methods: ["sign_and_send_transaction"],
//                    events: ["accounts_changed", "chain_changed"],
//                    accounts: [
//                        Account(blockchain: blockchain, address:"\(accountAddress)")!
//                    ]
//                )
//                try await Sign.instance.approve(proposalId: proposal.id, namespaces: sessionNamespaces)
//            } catch {
//                print(error)
//            }
//        }
    }
}
