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
    
    var pageBody: some View {
        VStack {
            PageIndicator(numberOfPages: 4, currentPage: 1)
            StyledLabel(text: viewModel.title, style: .body)
                .padding([.leading, .trailing], 20)
            WordSelection(selectedWords: viewModel.selectedWords, suggestions: viewModel.suggestions) { index, word in
                viewModel.send(.selectWord(index: index, word: word))
            }.padding([.top], 95)
            ErrorLabel(error: viewModel.error)
                .padding(.init(top: 16, leading: 20, bottom: 0, trailing: 20))
            Spacer()
        }
        .padding(.init(top: 10, leading: 16, bottom: 30, trailing: 16))
    }
}

private struct WordSelection: View {
    let selectedWords: [String]
    let suggestions: [[String]]
    let action: (Int, String) -> Void
    
    @State private var selectedIndex = 0
    @State private var isScrolling = false
    
    var body: some View {
        HStack {
            WordList(
                selectedIndex: $selectedIndex,
                isScrolling: $isScrolling,
                selectedWords: selectedWords
            )
            Image("select_arrow")
            SuggestionBox(
                suggestions: suggestions[selectedIndex],
                selectedSuggestion: selectedWords[selectedIndex]
            ) { suggestion in
                action(selectedIndex, suggestion)
                moveToNextIndex()
            }.opacity(isScrolling ? 0 : 1)
        }
        .padding(.init(top: 0, leading: 4, bottom: 0, trailing: 12))
    }
    
    private func moveToNextIndex() {
        for index in selectedIndex+1..<selectedWords.count {
            if selectedWords[index].isEmpty {
                selectedIndex = index
                return
            }
        }
        for index in 0..<selectedIndex {
            if selectedWords[index].isEmpty {
                selectedIndex = index
                return
            }
        }
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
