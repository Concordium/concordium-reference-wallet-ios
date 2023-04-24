//
//  RecoveryPhraseRecoverCompleteView.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 01/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct RecoveryPhraseRecoverCompleteView: Page {
    @ObservedObject var viewModel: RecoveryPhraseRecoverCompleteViewModel
    
    var pageBody: some View {
        VStack {
            Image("confirm")
                .resizable()
                .frame(width: 110, height: 110)
                .padding([.top, .bottom], 75)
                .foregroundColor(Pallette.primary)
            StyledLabel(text: viewModel.title, style: .body)
            Spacer()
            Button(viewModel.continueLabel) {
                viewModel.send(.finish)
            }.applyStandardButtonStyle()
        }.padding(.init(top: 10, leading: 16, bottom: 30, trailing: 16))
    }
}

struct RecoveryPhraseRecoverCompleteView_Previews: PreviewProvider {
    static var previews: some View {
        RecoveryPhraseRecoverCompleteView(
            viewModel: .init(
                title: "Your secret recovery phrase has been successfully entered! Tap continue to recover your accounts and identities.",
                continueLabel: "Continue"
            )
        )
    }
}
