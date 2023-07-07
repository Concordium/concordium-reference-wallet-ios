//
//  WalletConnectApprovalView.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 07/06/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Combine
import SwiftUI

class WalletConnectApprovalViewModel: ObservableObject {
    var didAccept: () -> Void
    var didDecline: () -> Void
    @Published var shouldAllowAccept: AnyPublisher<Bool, Never>

    init(
        didAccept: @escaping () -> Void,
        didDecline: @escaping () -> Void,
        shouldAllowAccept: AnyPublisher<Bool, Never>
    ) {
        self.didAccept = didAccept
        self.didDecline = didDecline
        self.shouldAllowAccept = shouldAllowAccept
    }
}

struct WalletConnectApprovalView<Content: View>: View {
    var title: String
    var contentView: Content
    @State private var shouldAllowAccept: Bool = false
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

                .disabled(!shouldAllowAccept)
                .background(!shouldAllowAccept ? Pallette.inactiveButton : Pallette.primary)
                .cornerRadius(10)
            }
            .padding()
        }.onReceive(viewModel.shouldAllowAccept) { shouldAllowAccept in
            self.shouldAllowAccept = shouldAllowAccept
        }
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
                shouldAllowAccept: .just(true)
            )
        )
        .previewLayout(PreviewLayout.sizeThatFits)
        .padding()
        .previewDisplayName("Default preview")
    }
}
