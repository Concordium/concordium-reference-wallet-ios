//
//  WordSelector.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 28/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import SwiftUI

struct WordSelection: View {
    let selectedWords: [String]
    let suggestions: (Int) -> [String]
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
                suggestions: suggestions(selectedIndex),
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
