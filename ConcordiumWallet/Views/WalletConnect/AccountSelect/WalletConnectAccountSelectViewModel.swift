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
    var didSelect: ((_ account: AccountDataType) -> ())
    var dismissView: (() -> Void)
    
    init(storageManager: StorageManagerProtocol, didSelect: @escaping (_ account: AccountDataType) -> (), dismissView: @escaping (() -> Void)) {
        self.storageManager = storageManager
        self.didSelect = didSelect
        self.dismissView = dismissView
    }
    
    func loadAccounts() {
        accounts = storageManager.getAccounts()
    }
    
    func didSelect(account: AccountDataType) {
        didSelect(account)
    }
}
