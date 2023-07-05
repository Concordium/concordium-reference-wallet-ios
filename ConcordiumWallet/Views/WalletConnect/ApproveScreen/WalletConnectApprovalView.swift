//
//  WalletConnectApprovalView.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 07/06/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import SwiftUI

class WalletConnectApprovalViewModel: ObservableObject {
    var didAccept: () -> Void
    var didDecline: () -> Void
    @Published var ready: Ready

    init(didAccept: @escaping () -> Void, didDecline: @escaping () -> Void, ready: Ready) {
        self.didAccept = didAccept
        self.didDecline = didDecline
        self.ready = ready
    }
}

struct WalletConnectApprovalView<Content: View>: View {
    var title: String
    var contentView: Content
    @ObservedObject var viewModel: WalletConnectApprovalViewModel

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .bold()
                .font(.system(size: 20))
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
                .disabled(!viewModel.ready.isReady)
                .background(Pallette.primary)
                .cornerRadius(10)
            }.padding()
        }
        .navigationBarBackButtonHidden()
//        .navigationBarHidden(true) // <- doesn't unhide after the view is popped...
    }
}

struct WalletConnectApprovalView_Previews: PreviewProvider {
    static var previews: some View {
        WalletConnectApprovalView(
            title: "walletconnect.connect.approve.title".localized,
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
                didDecline: {},
                ready: AlwaysReady()
            )
        )
        .previewLayout(PreviewLayout.sizeThatFits)
        .padding()
        .previewDisplayName("Default preview")
    }
}
