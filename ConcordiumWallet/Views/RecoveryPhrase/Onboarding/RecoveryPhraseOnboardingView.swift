//
//  RecoveryPhraseOnboardingView.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 01/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct RecoveryPhraseOnboardingView: Page {
    @ObservedObject var viewModel: RecoveryPhraseOnboardingViewModel
    
    var pageBody: some View {
        VStack {
            PageIndicator(numberOfPages: 4, currentPage: 1)
            StyledLabel(text: viewModel.message, style: .body, textAlignment: .leading)
            Spacer()
            Button(viewModel.continueLabel) {
                self.viewModel.send(.continueTapped)
            }.applyStandardButtonStyle()
        }
        .padding(.init(top: 10, leading: 16, bottom: 30, trailing: 16))
    }
}

struct RecoveryPhraseOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        RecoveryPhraseOnboardingView(viewModel: .init(
            message: "Some very long message",
            continueLabel: "Continue"
        ))
    }
}
