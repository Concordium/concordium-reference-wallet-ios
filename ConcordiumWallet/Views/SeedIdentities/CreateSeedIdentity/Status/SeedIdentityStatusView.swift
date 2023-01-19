//
//  SeedIdentityStatusView.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 05/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct SeedIdentityStatusView: Page {
    @ObservedObject var viewModel: SeedIdentityStatusViewModel
    
    var pageBody: some View {
        VStack {
            ScrollView {
                VStack {
                    if !viewModel.isNewIdentityAfterSettingUpTheWallet {
                        PageIndicator(numberOfPages: 4, currentPage: 3)
                    }
                    StyledLabel(text: viewModel.title, style: .heading, color: Pallette.primary)
                        .padding([.top, .bottom], 35)
                    StyledLabel(text: viewModel.body, style: .body, textAlignment: .leading)
                        .padding(.init(top: 0, leading: 16, bottom: 40, trailing: 16))
                    IdentityCard(
                        viewModel: viewModel.identityViewModel
                    )
                }.alert(isPresented: $viewModel.isIdentityConfirmed) { 
                    Alert(title: Text("newaccount.title".localized), message: Text((String(format: "newaccount.message".localized, viewModel.identityViewModel.nickname))), primaryButton: .default(Text("newaccount.create".localized), action: {
                        viewModel.send(.makeNewAccountRequest)
                    }), secondaryButton: .default(Text("newaccount.later".localized)))
                }
            }
            Spacer()
            Button(viewModel.continueLabel) {
                viewModel.isNewIdentityAfterSettingUpTheWallet ? viewModel.send(.finishNewIdentityAfterSettingUpTheWallet) : viewModel.send(.finish)
            }.applyStandardButtonStyle().alert(item: $viewModel.identityRejectionError) { error in
                Alert(title: Text("newidentityrejected.title".localized), message: Text((String(format: "newidentityrejected.message".localized, error.description))), primaryButton: .default(Text("newidentityrejected.tryagain".localized), action: {
                    viewModel.send(.makeNewIdentityRequest)
                }), secondaryButton: .default(Text("newidentityrejected.later".localized)))
            }
        }.padding(.init(top: 10, leading: 16, bottom: 16, trailing: 30))
    }
}

struct SeedIdentityStatusView_Previews: PreviewProvider {
    static var previews: some View {
        SeedIdentityStatusView(
            viewModel: .init(
                title: "Verification request submitted!",
                body: """
Your request has been submitted with the identity provider. Now you just have to wait for a moment for them to process your submission. Once your identity is verified, you can create your first account.
""",
                identityViewModel: .init(
                    index: 1,
                    expirationDate: "Expires September, 2024",
                    image: nil,
                    state: .pending
                ),
                continueLabel: "Continue",
                isNewIdentityAfterSettingUpTheWallet: false
            )
        )
    }
}
