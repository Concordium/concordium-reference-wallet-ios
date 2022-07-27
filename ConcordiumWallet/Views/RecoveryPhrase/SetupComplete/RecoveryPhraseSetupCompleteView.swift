//
//  RecoveryPhraseSetupCompleteView.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 27/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct RecoveryPhraseSetupCompleteView: Page {
    @ObservedObject var viewModel: RecoveryPhraseSetupCompleteViewModel
    
    var pageBody: some View {
        ZStack {
            VStack {
                PageIndicator(numberOfPages: 4, currentPage: 1)
                    .padding([.top, .bottom], 10)
                Text(verbatim: viewModel.title)
                    .labelStyle(.body)
                    .multilineTextAlignment(.center)
                Spacer()
                Button(viewModel.continueLabel) {
                    viewModel.send(.finish)
                }
                .applyStandardButtonStyle()
                .padding(.init(top: 0, leading: 16, bottom: 30, trailing: 16))
            }
            Image("confirm")
                .resizable()
                .frame(width: 110, height: 110)
                .foregroundColor(Pallette.primary)
        }
    }
}

struct RecoveryPhraseSetupCompleteView_Previews: PreviewProvider {
    static var previews: some View {
        RecoveryPhraseSetupCompleteView(
            viewModel: .init(
                title: "Your secret recovery phrase has been successfully setup!",
                continueLabel: "Continue"
            )
        )
    }
}
