//
//  WalletConnectApprovalView.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 07/06/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import SwiftUI

struct WalletConnectApprovalViewModel {
    var didAccept: () -> Void
    var didDecline: () -> Void

    init(didAccept: @escaping () -> Void, didDecline: @escaping () -> Void) {
        self.didAccept = didAccept
        self.didDecline = didDecline
    }
}

struct WalletConnectApprovalView<Content: View>: View {
    var title: String
    var subtitle: String?
    var contentView: Content
    var viewModel: WalletConnectApprovalViewModel
    var isAcceptButtonDisabled = false
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .bold()
                .font(.system(size: 20))
            if let subtitle {
                Text(subtitle)
                    .padding()
                    .multilineTextAlignment(.center)
            }
            contentView
            Spacer()
            HStack(spacing: 16) {
                Button(action: viewModel.didDecline) {
                    Text("Reject")
                        .foregroundColor(Pallette.error)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 10,
                                style: .continuous
                            )
                            .stroke(Pallette.error, lineWidth: 2)
                        )
                }

                Button(action: viewModel.didAccept) {
                    Text("Accept")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .disabled(isAcceptButtonDisabled)
                .background(isAcceptButtonDisabled ? Pallette.inactiveButton : Pallette.primary)
                .cornerRadius(10)
            }
            .padding()
        }
    }
}

struct WalletConnectApprovalView_Previews: PreviewProvider {
    static var previews: some View {
        WalletConnectApprovalView(
            title: "walletconnect.connect.approve.title".localized,
            subtitle: "walletconnect.connect.approve.subtitle".localizedNonempty,
            contentView: WalletConnectProposalApprovalView(
                accountName: "My Account",
                proposal: .init(
                    dappName: "My dApp",
                    namespaces: [
                        ProposalData.ProposalNamespace(
                            methods: ["method1", "method2"],
                            events: ["event1", "event2"]),
                    ]
                )
            ),
            viewModel: .init(
                didAccept: {},
                didDecline: {}
            )
        )
        .previewLayout(PreviewLayout.sizeThatFits)
        .padding()
        .previewDisplayName("Default preview")
    }
}
