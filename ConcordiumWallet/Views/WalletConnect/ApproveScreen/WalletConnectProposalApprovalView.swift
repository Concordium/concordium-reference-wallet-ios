//
//  WalletConnectProposalApprovalView.swift
//  Mock
//
//  Created by Michael Olesen on 27/06/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import SwiftUI
import WalletConnectSign

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

