//
//  SubmittedSeedAccountView.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 7.11.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct SubmittedSeedAccountView: Page {
    @ObservedObject var viewModel: SubmittedSeedAccountViewModel
    
    var pageBody: some View {
        VStack {
            ScrollView {
                VStack {
                    StyledLabel(text: viewModel.title, style: .heading, color: Pallette.primary)
                        .padding([.top, .bottom], 25)
                    StyledLabel(text: viewModel.body, style: .body)
                        .padding(.init(top: 0, leading: 16, bottom: 60, trailing: 16))
                    IdentityCard(
                        viewModel: viewModel.identityViewModel,
                        borderColor: Pallette.primary
                    ).padding([.bottom], 30)
                    AccountCard(viewModel: viewModel.accountViewModel)
                    Spacer()
                    Button(viewModel.finishAccount) {
                        viewModel.send(.finishAccount)
                    }.applyStandardButtonStyle()
                }.padding(.init(top: 10, leading: 16, bottom: 30, trailing: 16))
            }
        }
    }
}

private struct AccountCard: View {
    @ObservedObject var viewModel: SubmittedAccountCardViewModel
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    StyledLabel(text: viewModel.accountTitle, style: .body)
                    StyledLabel(text: viewModel.identityNickname, style: .body, color: Pallette.fadedText)
                    Spacer()
                }
                HStack {
                    StyledLabel(
                        text: viewModel.totalLabel,
                        style: .body
                    )
                    Spacer()
                    StyledLabel(
                        text: viewModel.totalAmount.displayValueWithGStroke(),
                        style: .body
                    )
                }
                HStack {
                    StyledLabel(
                        text: viewModel.atDisposalLabel,
                        style: .body
                    )
                    Spacer()
                    StyledLabel(
                        text: viewModel.atDisposalAmount.displayValueWithGStroke(),
                        style: .body
                    )
                }
            }
            .padding(10)
        }.background(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder()
                .foregroundColor(Pallette.primary)
        )
    }
}

struct SubmittedSeedAccountView_Previews: PreviewProvider {
    static var previews: some View {
        SubmittedSeedAccountView(
            viewModel: .init(
                title: "Account submitted",
                body: "Once it's finalized you can use the account from the account overview.",
                finishAccount: "Finish",
                identityViewModel: .init(
                    index: 0,
                    expirationDate: nil,
                    image: nil,
                    state: .pending
                ),
                accountViewModel: .init(
                    state: .notAvailable,
                    totalLabel: "Total",
                    atDisposalLabel: "At disposal"
                )
            )
        )
    }
}
