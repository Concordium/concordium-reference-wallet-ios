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
    var didSelect: ((_ account: AccountDataType) -> ())?
    // TODO: implement WalletConnectClient
    init(storageManager: StorageManagerProtocol, proposal: Session.Proposal) {
        self.proposal = proposal
        self.storageManager = storageManager
    }
    
    func getAccounts() {
        accounts = storageManager.getAccounts()
    }
    
    func didSelect(account: AccountDataType) {
        didSelect?(account)
    }
}
