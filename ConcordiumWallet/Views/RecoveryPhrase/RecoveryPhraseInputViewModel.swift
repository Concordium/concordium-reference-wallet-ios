//
//  RecoveryPhraseInputViewModel.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 28/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum RecoveryPhraseInputEvent {
    case clearAll
    case clearBelow(index: Int)
    case wordSelected(index: Int, word: String)
}

class RecoveryPhraseInputViewModel: PageViewModel<RecoveryPhraseInputEvent> {
    @Published var title: String
    @Published var clearAll: String
    @Published var clearBelow: String
    @Published var selectedWords: [String]
    @Published var currentInput: String
    @Published var currentSuggestions: [String]
    @Published var error: String?
    
    init(
        title: String,
        clearAll: String,
        clearBelow: String,
        selectedWords: [String],
        currentInput: String,
        currentSuggestions: [String],
        error: String?
    ) {
        self.title = title
        self.clearAll = clearAll
        self.clearBelow = clearBelow
        self.selectedWords = selectedWords
        self.currentInput = currentInput
        self.currentSuggestions = currentSuggestions
        self.error = error
    }
}
