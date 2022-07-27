//
//  RecoveryPhraseConfirmPhraseViewModel.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 25/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum RecoveryPhraseConfirmPhraseEvent {
    case selectWord(index: Int, word: String)
}

class RecoveryPhraseConfirmPhraseViewModel: PageViewModel<RecoveryPhraseConfirmPhraseEvent> {
    @Published var title: String
    @Published var suggestions: [[String]]
    @Published var selectedWords: [String]
    
    init(
        title: String,
        suggestions: [[String]],
        selectedWords: [String]
    ) {
        self.title = title
        self.suggestions = suggestions
        self.selectedWords = selectedWords
    }
}
