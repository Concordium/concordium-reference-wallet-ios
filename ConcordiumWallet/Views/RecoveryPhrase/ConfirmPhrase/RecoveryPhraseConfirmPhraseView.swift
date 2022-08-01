//
//  RecoveryPhraseConfirmPhraseView.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 25/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct RecoveryPhraseConfirmPhraseView: Page {
    @ObservedObject var viewModel: RecoveryPhraseConfirmPhraseViewModel
    
    @State private var selectedIndex = 0
    
    var pageBody: some View {
        VStack {
            PageIndicator(numberOfPages: 4, currentPage: 1)
            StyledLabel(text: viewModel.title, style: .body)
                .padding([.leading, .trailing], 20)
            WordSelection(
                selectedWords: viewModel.selectedWords,
                selectedIndex: $selectedIndex,
                suggestions: viewModel.suggestions[selectedIndex],
                action: { word in
                    viewModel.send(.selectWord(index: selectedIndex, word: word))
                }
            ).padding([.top], 95)
            ErrorLabel(error: viewModel.error)
                .padding(.init(top: 16, leading: 20, bottom: 0, trailing: 20))
            Spacer()
        }
        .padding(.init(top: 10, leading: 16, bottom: 30, trailing: 16))
    }
}

struct RecoveryPhraseConfirmPhraseView_Previews: PreviewProvider {
    static var previews: some View {
        RecoveryPhraseConfirmPhraseView(
            viewModel: .init(
                title: "Pick the correct suggestion on the right, for each index.",
                suggestions: [
                    ["ariel", "gossipy", "violently", "damage"]
                ] + Array(repeating: [], count: 23),
                selectedWords: ["Ariel"] + Array(repeating: "", count: 23),
                error: "Incorrect secret recovery phrase. Please verify that each index has the right word."
            )
        )
    }
}
