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
    let accountName: String
    let proposal: ProposalData
    
    var boxText: AttributedString {
        var d = AttributedString(proposal.dappName)
        var a = AttributedString(accountName)
        d.font = .body.bold()
        a.font = .body.bold()
        return "Open connection from application " + d + " to account " + a
    }

    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Group {
                    Image("connection_socket")
                    Text(boxText)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .padding()
            }
            .background(.black)
            .cornerRadius(10)
            .padding(16)

            VStack(alignment: .leading, spacing: 12) {
                Text("Approving the connection will allow the application to request the following kinds of actions to be performed using the connected account:")
                VStack(alignment: .leading) {
                    Text("•  Sign a message")
                    Text("•  Sign and send a transaction")
                }
                Text("No actions will be performed without your explicit approval.").multilineTextAlignment(.leading)
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
