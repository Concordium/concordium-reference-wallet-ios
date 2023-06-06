//
//  WalletConnectAccountSelectView.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 01/06/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import SwiftUI
struct WalletConnectAccountSelectView: View {
    @StateObject var viewModel: WalletConnectAccountSelectViewModel

    var body: some View {
        Text("walletConnct.select.account.header".localized)
            .multilineTextAlignment(.center)
            .padding(32)
        List($viewModel.accounts, id: \.address) { account in
            WalletConnectAccountItemView(account: account.wrappedValue) {
                viewModel.didSelect(accountAddress: account.wrappedValue.address)
            }
        }
        .listRowSeparator(.hidden)
        .listStyle(.plain)
        .onAppear {
            viewModel.getAccounts()
        }
    }
}
