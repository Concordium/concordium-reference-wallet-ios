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
    
    var didAccept: (() -> ())
    var didDecline: (() -> ())
    
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
   
    
//    {connectedSession.namespaces &&
//                                  Object.entries(connectedSession.namespaces).map(([key, ns]) => (
//                                   <li key={key}>
//                                       Key: {key}
//                                       Accounts: {ns.accounts.join(', ')}
//                                       Methods: {ns.methods.join(', ')}
//                                       Events: {ns.events.join(', ')}
//                                       Extension: {JSON.stringify(ns.extension)}
//                                   </li>
//                               ))}
    let accountName: String
    
    init(proposal: Session.Proposal) {
        accountName = proposal.proposer.name
    }
    
    var body: some View {
        VStack {
            HStack {
                Image("connection_socket")
                VStack {
                    Text("About to open connection betweeen:").foregroundColor(.white) // todo localize
                    Text("Account name").foregroundColor(.white)
                }
            }
            .padding(16)
            .background(.black)
            .cornerRadius(10)
            HStack {
                Text("The service will be able to see: ")
                Spacer()
            }
            .padding(16)
            Spacer()
        }
    }
}

struct WalletConnectApprovalView_Previews: PreviewProvider {
    static var previews: some View {
        WalletConnectApprovalView(
            title: "walletconnect.approval.title".localized,
            subtitle:"somedApp" + " " + "walletconnect.approval.subtitle".localized,
            contentView: WalletConnectProposalApprovalView(proposal: ),
            viewModel: .init(didAccept: {}, didDecline: {}
            )
        )
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("Default preview")
    }
}

protocol SessionProposal {

}

extension Session.Proposal: SessionProposal {
    
}
