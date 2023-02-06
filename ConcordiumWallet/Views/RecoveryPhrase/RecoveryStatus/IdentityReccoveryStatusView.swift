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
                .foregroundColor(Pallette.primary)
            StyledLabel(
                text: viewModel.title,
                style: .title,
                color: Pallette.primary
            ).padding([.top, .bottom], 44)
            StyledLabel(
                text: viewModel.message,
                style: .body,
                color: Pallette.text
            ).padding(.init(top: 0, leading: 16, bottom: 44, trailing: 16)).fixedSize(horizontal: false, vertical: true)
            if case let .success(identities, accounts) = viewModel.status {
                IdentityList(
                    identities: identities,
                    accounts: accounts
                )
            } else if case let .partial(identities, accounts, failedIdentityProviders) = viewModel.status {
                IdentityList(
                    identities: identities,
                    accounts: accounts
                )
            }
            Spacer()
            buttons
        }.padding(.init(top: 10, leading: 16, bottom: 30, trailing: 16))
    }
    
    @ViewBuilder
    private var buttons: some View {
        switch viewModel.status {
        case .fetching:
            EmptyView()
//        case .emptyResponse:
//            Button(viewModel.tryAgain) {
//                viewModel.send(.fetchIdentities)
//            }
//            .applyStandardButtonStyle()
//            .padding([.bottom], 16)
//            Button(viewModel.changeRecoveryPhrase) {
//                viewModel.send(.changeRecoveryPhrase)
//            }.applyStandardButtonStyle()
        case .success, .emptyResponse:
            Button(viewModel.continueLongLabel) {
                viewModel.send(.finish)
            }.applyStandardButtonStyle()
        case .partial:
            HStack(spacing: 16.0) {
                Button(viewModel.tryAgain) {
                    viewModel.send(.fetchIdentities)
                }
                .applyStandardButtonStyle()
                Button(viewModel.continueLabel) {
                    viewModel.send(.finish)
                }
                .applyStandardButtonStyle()
            }
        }
    }
    
//    private var titleColor: Color {
//        if viewModel.status == .emptyResponse {
//            return Pallette.error
//        } else {
//            return Pallette.primary
//        }
//    }
    
//    private var messageColor: Color {
//        if viewModel.status == .fetching {
//            return Pallette.fadedText
//        } else {
//            return Pallette.text
//        }
//    }
    
    private var imageName: String {
        switch viewModel.status {
        case .fetching:
            return "import_pending"
        case .success, .emptyResponse:
            return "confirm"
        case .partial:
            return "partial"
        }
    }
}

private struct IdentityList: View {
    let identities: [IdentityDataType]
    let accounts: [AccountDataType]
    
    var body: some View {
        ScrollView {
            ForEach(identities, id: \.id) { identity in
                StyledLabel(
                    text: identity.nickname,
                    style: .subheading,
                    weight: .semibold,
                    textAlignment: .leading
                )
                Spacer()
                StyledLabel(
                    text: "identityrecovery.status.accountheader".localized,
                    style: .body,
                    weight: .semibold,
                    textAlignment: .leading
                )
                ForEach(accounts, id: \.address) { account in
                    if account.identity!.id == identity.id {
                        StyledLabel(
                            text: "\(account.displayName) - \(GTU(intValue: account.finalizedBalance).displayValueWithGStroke())",
                            style: .body,
                            textAlignment: .leading
                        )
                    }
                }
                Spacer()
                Spacer()
            }.frame(maxWidth: .infinity)
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
                continueLongLabel: "Continue to wallet",
                continueLabel: "Continue",
                tryAgain: "Try again"
//                changeRecoveryPhrase: "Enter another recovery phrase"
            )
        )
        
//        IdentityReccoveryStatusView(
//            viewModel: .init(
//                status: .emptyResponse,
//                title: "We found nothing to recover.",
//                message: """
//There was no accounts to be found for the secret recovery phrase. Did you maybe enter a wrong recovery phrase?
//
//If you only have an identity and no accounts, this can also be the reason. In this case please specify which identity provider you used to get your identity, so we can send them a request.
//""",
//                continueLabel: "Continue to wallet",
//                tryAgain: "Try again"
////                changeRecoveryPhrase: "Enter another recovery phrase")
//        )
        
//        IdentityReccoveryStatusView(
//            viewModel: .init(
//                status: .success([IdentityEntity()], [AccountEntity()]),
//                title: "Recovery finished",
//                message: "You have successfully recovered:",
//                continueLabel: "Continue to wallet",
//                tryAgain: "Try again"
////                changeRecoveryPhrase: "Enter another recovery phrase"
//            )
//        )
    }
}
