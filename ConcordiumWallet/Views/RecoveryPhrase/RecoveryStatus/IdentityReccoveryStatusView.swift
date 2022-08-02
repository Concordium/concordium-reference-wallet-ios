//
//  IdentityReccoveryStatusView.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 01/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct IdentityReccoveryStatusView: Page {
    @ObservedObject var viewModel: IdentityRecoveryStatusViewModel
    
    var pageBody: some View {
        VStack(spacing: 0) {
            Image(imageName)
                .resizable()
                .frame(width: 110, height: 110)
                .foregroundColor(titleColor)
            StyledLabel(
                text: viewModel.title,
                style: .title,
                color: titleColor
            ).padding([.top, .bottom], 44)
            StyledLabel(
                text: viewModel.message,
                style: .body,
                color: messageColor
            ).padding(.init(top: 0, leading: 16, bottom: 44, trailing: 16))
            Spacer()
            buttons
        }.padding(.init(top: 10, leading: 16, bottom: 30, trailing: 16))
    }
    
    @ViewBuilder
    private var buttons: some View {
        switch viewModel.status {
        case .fetching:
            EmptyView()
        case .emptyResponse:
            Button(viewModel.tryAgain) {
                viewModel.send(.fetchIdentities)
            }
            .applyStandardButtonStyle()
            .padding([.bottom], 16)
            Button(viewModel.changeRecoveryPhrase) {
                viewModel.send(.changeRecoveryPhrase)
            }.applyStandardButtonStyle()
        case .failed, .success:
            Button(viewModel.continueLabel) {
                viewModel.send(.finish)
            }.applyStandardButtonStyle()
        }
    }
    
    private var titleColor: Color {
        if viewModel.status == .emptyResponse {
            return Pallette.error
        } else {
            return Pallette.primary
        }
    }
    
    private var messageColor: Color {
        if viewModel.status == .fetching {
            return Pallette.fadedText
        } else {
            return Pallette.text
        }
    }
    
    private var imageName: String {
        switch viewModel.status {
        case .fetching:
            return "import_pending"
        case .emptyResponse:
            return "error"
        case .failed, .success:
            return "confirm"
        }
    }
}

struct IdentityReccoveryStatusView_Previews: PreviewProvider {
    static var previews: some View {
        IdentityReccoveryStatusView(
            viewModel: .init(
                status: .fetching,
                title: "Recovering IDs and accounts",
                message: "Scanning the Concordium blockchain. Hang on while we find your account and identities.",
                continueLabel: "Continue to wallet",
                tryAgain: "Try again",
                changeRecoveryPhrase: "Enter another recovery phrase"
            )
        )
        
        IdentityReccoveryStatusView(
            viewModel: .init(
                status: .failed,
                title: "We found nothing to recover.",
                message: """
There was no accounts to be found for the secret recovery phrase. Did you maybe enter a wrong recovery phrase?

If you only have an identity and no accounts, this can also be the reason. In this case please specify which identity provider you used to get your identity, so we can send them a request.
""",
                continueLabel: "Continue to wallet",
                tryAgain: "Try again",
                changeRecoveryPhrase: "Enter another recovery phrase")
        )
        
        IdentityReccoveryStatusView(
            viewModel: .init(
                status: .success([IdentityEntity()]),
                title: "Recovery finished",
                message: "You have succesfully recovered:",
                continueLabel: "Continue to wallet",
                tryAgain: "Try again",
                changeRecoveryPhrase: "Enter another recovery phrase"
            )
        )
    }
}
