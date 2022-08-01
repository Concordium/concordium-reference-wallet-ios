//
//  RecoveryPhraseInputView.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 28/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct RecoveryPhraseInputView: Page {
    @ObservedObject var viewModel: RecoveryPhraseInputViewModel
    
    @State private var selectedIndex = 0
    
    var pageBody: some View {
        VStack {
            StyledLabel(text: viewModel.title, style: .body)
            HStack {
                Button(viewModel.clearAll) {
                    viewModel.send(.clearAll)
                    selectedIndex = 0
                }.applyStandardButtonStyle(padding: 8, fillWidth: false)
                Button(viewModel.clearBelow) {
                    viewModel.send(.clearBelow(index: selectedIndex))
                }.applyStandardButtonStyle(padding: 8, fillWidth: false)
            }
            .padding([.top, .bottom], 8)
            WordSelection(
                selectedWords: viewModel.selectedWords,
                selectedIndex: $selectedIndex,
                suggestions: viewModel.currentSuggestions,
                editable: true,
                currentInput: $viewModel.currentInput,
                action: { word in viewModel.send(.wordSelected(index: selectedIndex, word: word)) }
            )
            ErrorLabel(error: viewModel.error)
            Spacer()
        }.padding(.init(top: 10, leading: 16, bottom: 30, trailing: 16))
    }
}

struct RecoverPhraseInputView_Previews: PreviewProvider {
    static var previews: some View {
        RecoveryPhraseInputView(
            viewModel: .init(
                title: "Enter the correct word for each index.",
                clearAll: "Clear all",
                clearBelow: "Clear below",
                selectedWords: Array(repeating: "", count: 24),
                currentInput: "",
                currentSuggestions: [],
                error: nil
            )
        )
    }
}
