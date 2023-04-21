//
//  RecoveryPhraseRecoverIntroView.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 28/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct RecoveryPhraseRecoverIntroView: Page {
    @ObservedObject var viewModel: RecoveryPhraseRecoverIntroViewModel
    
    var pageBody: some View {
        VStack {
            StyledLabel(text: viewModel.title, style: .title)
                .padding([.top], 60)
            StyledLabel(text: viewModel.body, style: .body, textAlignment: .leading)
                .padding([.top, .leading, .trailing], 16)
            Spacer()
            Button(viewModel.continueLabel) {
                viewModel.send(.finish)
            }.applyStandardButtonStyle()
        }
        .padding(.init(top: 10, leading: 16, bottom: 30, trailing: 16))
        .frame(maxWidth: .infinity)
    }
}

struct RecoveryPhraseRecoverIntroView_Previews: PreviewProvider {
    static var previews: some View {
        RecoveryPhraseRecoverIntroView(
            viewModel: .init(
                title: "How to recover your wallet:",
                body: """
There are two steps to recovering a wallet:

1. Entering your secret recover phrase
2. Recovering your accounts and identities

The first step is manual process, in which you have to enter all your 24 words one by one.

The second step is most often automatic, but in some cases you will have to make some additional inputs. We’ll get back to that.

Let’s get to the secrect recovery phrase!
""",
                continueLabel: "Continue"
            )
        )
    }
}
