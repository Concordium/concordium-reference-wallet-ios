//
//  SubmitSeedAccountView.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 09/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct SubmitSeedAccountView: Page {
    @ObservedObject var viewModel: SubmitSeedAccountViewModel
    
    var pageBody: some View {
        VStack {
            if !viewModel.isNewAccountAfterSettingUpTheWallet {
                PageIndicator(numberOfPages: 4, currentPage: 4)
                    .padding([.top], 10)
            }
            ScrollView {
                VStack {
                    StyledLabel(text: viewModel.title, style: .heading, color: Pallette.primary)
                        .padding([.top, .bottom], 25)
                    StyledLabel(text: viewModel.body, style: .body, textAlignment: .leading)
                        .padding(.init(top: 0, leading: 16, bottom: 60, trailing: 16))
                    IdentityCard(
                        viewModel: viewModel.identityViewModel,
                        borderColor: Pallette.primary
                    ).padding([.bottom], 30)
                    CreateAccountCard(viewModel: viewModel.accountViewModel) {
                        viewModel.send(.submitAccount)
                    }
                }.padding(.init(top: 10, leading: 16, bottom: 30, trailing: 16))
            }
        }.alert(item: $viewModel.identityRejectionError) { error in
            Alert(title: Text("identityrejected.title".localized), message: Text((String(format: "identityrejected.message".localized, error.description))), dismissButton: .default(Text("identityrejected.tryagain".localized), action: {
                viewModel.send(.makeNewIdentityRequest)
            }))
        }
    }
}

private struct CreateAccountCard: View {
    @ObservedObject var viewModel: AccountCardViewModel
    let submitAccount: () -> Void
    
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
            .blur(radius: viewModel.state == .pending ? 0 : 10)
            Button(viewModel.submitAccount) {
                submitAccount()
            }
            .applyStandardButtonStyle(disabled: viewModel.state == .notAvailable)
            .padding(.init(top: 30, leading: 60, bottom: 30, trailing: 60))
            .opacity(viewModel.state == .pending ? 0 : 1)
        }.background(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder()
                .foregroundColor(Pallette.primary)
        )
    }
}

struct SubmitSeedAccountView_Previews: PreviewProvider {
    static var previews: some View {
        SubmitSeedAccountView(
            viewModel: .init(
                title: "Account submission",
                body: """
Once the identity provider has verified your identity, you will be able to submit your first Concordium account. So hang on for a bit and wait for them to finish. You can also come back later to submit your account.
                
When you have submitted your account, you will be taken to the wallet.
""",
                identityViewModel: .init(
                    index: 0,
                    expirationDate: nil,
                    image: nil,
                    state: .pending
                ),
                accountViewModel: .init(
                    state: .notAvailable,
                    totalLabel: "Total",
                    atDisposalLabel: "At disposal",
                    submitAccount: "Submit account"
                ),
                isNewAccountAfterSettingUpTheWallet: false
            )
        )
    }
}
