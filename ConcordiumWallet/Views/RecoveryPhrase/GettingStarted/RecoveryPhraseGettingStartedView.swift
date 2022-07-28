//
//  RecoveryPhraseGettingStartedView.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 29/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI
import Combine

struct RecoveryPhraseGettingStartedView: Page {
    @ObservedObject var viewModel: RecoveryPhraseGettingStartedViewModel
    
    var pageBody: some View {
        ScrollView {
            VStack {
                StyledLabel(text: viewModel.title, style: .title)
                    .padding([.top, .bottom], 60)
                GettingStartedSection(section: viewModel.createNewWalletSection, bottomPadding: 70) {
                    viewModel.send(.createNewWallet)
                }
                GettingStartedSection(section: viewModel.recoverWalletSection, bottomPadding: 30) {
                    viewModel.send(.recoverWallet)
                }
            }.frame(maxWidth: .infinity)
                .padding([.leading, .trailing], 36)
        }
    }
}

private struct GettingStartedSection: View {
    let section: RecoveryPhraseGettingStartedViewModel.Section
    let bottomPadding: CGFloat?
    let action: () -> Void
    
    init(
        section: RecoveryPhraseGettingStartedViewModel.Section,
        bottomPadding: CGFloat? = nil,
        action: @escaping () -> Void
    ) {
        self.section = section
        self.bottomPadding = bottomPadding
        self.action = action
    }
    
    @ViewBuilder
    var body: some View {
        HStack {
            StyledLabel(text: section.title, style: .body, weight: .bold, textAlignment: .leading)
            Spacer()
        }.padding([.bottom], 10)
        HStack {
            StyledLabel(text: section.body, style: .body, textAlignment: .leading)
            Spacer()
        }
        if let bottomPadding = bottomPadding {
            Button(section.buttonTitle, action: action)
                .applyStandardButtonStyle()
                .padding([.bottom], bottomPadding)
        } else {
            Button(section.buttonTitle, action: action)
                .applyStandardButtonStyle()
        }
    }
}

struct RecoveryPhraseGettingStartedView_Previews: PreviewProvider {
    static var previews: some View {
        RecoveryPhraseGettingStartedView(viewModel: .init(
            title: "Are you new to concordium?",
            createNewWalletSection: .init(
                title: "Create new wallet",
                body: "Description of recovery phrase\nOn multiple lines",
                buttonTitle: "Set up fresh wallet"
            ),
            recoverWalletSection: .init(
                title: "Recover wallet",
                body: "Description of recover wallet\nOn multiple lines",
                buttonTitle: "Recover wallet"
            )
        ))
    }
}
