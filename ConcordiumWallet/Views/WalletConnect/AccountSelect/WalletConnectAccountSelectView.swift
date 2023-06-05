//
//  WalletConnectAccountSelectView.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 01/06/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import SwiftUI

struct WalletConnectAccountSelectView: View {
    var storageManager: StorageManagerProtocol
    @State var accounts: [AccountDataType] = []

    var body: some View {
        Text("walletConnct.select.account.header".localized)
            .multilineTextAlignment(.center)
            .padding(32)
        List(accounts, id: \.address) { account in
            WalletConnectAccountItemView(account: account)              
        }
        .listStyle(.plain)
        .onAppear {
            accounts = storageManager.getAccounts()
        }
    }
}
