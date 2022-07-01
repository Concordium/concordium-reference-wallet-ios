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
            Text(verbatim: "Placeholder!")
            Button("Continue") {
                self.viewModel.send(.continueTapped)
            }.applyStandardButtonStyle()
        }.padding([.bottom], 20)
    }
}

struct RecoveryPhraseOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        RecoveryPhraseOnboardingView(viewModel: .init())
    }
}
