//
//  WalletConnectApprovalView.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 07/06/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import SwiftUI

struct WalletConnectApprovalView: View {
    
    var title: String
    var subtitle: String?
    
    var body: some View {
        VStack {
            Text(title)
            if let subtitle {
                Text(subtitle)
            }
        }
    }
}

struct WalletConnectProposalApprovalView: View {
    var body: some View {
        HStack {
            Image(systemName: "plus")
            VStack {
                Text("About to open connection betweeen:") // todo localize
                Text("Account name")
                Text("dApp name")

            }
        }
    }
}

struct WalletConnectApprovalView_Previews: PreviewProvider {
    static var previews: some View {
        WalletConnectApprovalView(
            title: "walletconnect.approval.title".localized,
            subtitle: "walletconnect.approval.subtitle".localized
        )
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("Default preview")
    }
}
