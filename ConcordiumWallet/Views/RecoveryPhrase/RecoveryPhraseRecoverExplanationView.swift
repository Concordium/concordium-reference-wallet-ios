//
//  RecoveryPhraseRecoverExplanationView.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 28/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct RecoveryPhraseRecoverExplanationView: Page {
    @ObservedObject var viewModel: RecoveryPhraseRecoverExplanationViewModel
    
    var pageBody: some View {
        VStack {
            StyledLabel(text: "Placeholder", style: .title)
            Spacer()
            Button("Continue") {
                viewModel.send(.finish)
            }.applyStandardButtonStyle()
        }.padding(.init(top: 10, leading: 16, bottom: 30, trailing: 16))
    }
}

struct RecoveryPhraseRecoverExplanationView_Previews: PreviewProvider {
    static var previews: some View {
        RecoveryPhraseRecoverExplanationView(
            viewModel: .init()
        )
    }
}
