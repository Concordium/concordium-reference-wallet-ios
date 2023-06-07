//
//  WalletConnectApprovalView.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 07/06/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import SwiftUI
import WalletConnectSign

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
            HStack {
                Button {
                    viewModel.didDecline()
                } label: {
                    Text("Decline")
                        .foregroundColor(.white)
                        .padding()
                }
                .background(Pallette.primary)
                .cornerRadius(10)
                .padding()
                Spacer()
                Button {
                    viewModel.didAccept()
                } label: {
                    Text("Accept")
                        .foregroundColor(.white)
                        .padding()
                }
                .background(Pallette.primary)
                .cornerRadius(10)
            }.padding()
        }
    }
}

struct WalletConnectProposalApprovalView: View {
    let proposal: ProposalData

    init(proposal: ProposalData) {
        self.proposal = proposal
    }

    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Image("connection_socket")
                VStack {
                    Text("About to open connection betweeen:").foregroundColor(.white) // todo localize
                    Text(proposal.dappName)
                        .foregroundColor(.white)
                }
            }
            .padding(16)
            .background(.black)
            .cornerRadius(10)

            VStack(alignment: .leading, spacing: 24) {
                Text("If you approve the connection, then \(proposal.dappName) will be able to request the wallet to perform certain actions on your behalf. ")
                Text("This only allows \(proposal.dappName) to send requests to the wallet. Every interaction will still need your explicit approval.").multilineTextAlignment(.leading)
            }
            .padding()
            Spacer()
        }
    }
}

struct WalletConnectApprovalView_Previews: PreviewProvider {
    static var previews: some View {
        WalletConnectApprovalView(
            title: "Connection approval".localized,
            subtitle: "somedApp" + " " + "walletconnect.approval.subtitle".localized,
            contentView: WalletConnectProposalApprovalView(
                proposal: .init(
                    dappName: "dApp",
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

struct ProposalData {
    var dappName: String
    var namespaces: [ProposalNamespace]
    struct ProposalNamespace: Hashable {
        let methods: [String]
        let events: [String]
    }
}

extension Session.Proposal {
    var proposalNamespaces: [ProposalData.ProposalNamespace] {
        requiredNamespaces.map { _, namespace in
            ProposalData.ProposalNamespace(
                methods: namespace.methods.sorted(),
                events: namespace.events.sorted()
            )
        }
    }

    var proposalData: ProposalData {
        ProposalData(dappName: proposer.name, namespaces: proposalNamespaces)
    }
}
