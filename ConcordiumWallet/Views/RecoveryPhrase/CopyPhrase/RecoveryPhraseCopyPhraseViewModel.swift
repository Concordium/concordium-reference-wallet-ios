//
//  RecoveryPhraseCopyViewModel.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 29/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum RecoveryPhraseCopyPhraseEvent {
    case showPhrase
    case confirmBoxTapped
    case continueTapped
}

enum RecoveryPhraseState: Equatable {
    case hidden(message: String)
    case shown(recoveryPhrase: RecoveryPhrase)
}

class RecoveryPhraseCopyPhraseViewModel: PageViewModel<RecoveryPhraseCopyPhraseEvent> {
    @Published var title: String
    @Published var recoveryPhrase: RecoveryPhraseState
    @Published var copyValidationTitle: String
    @Published var hasCopiedPhrase: Bool
    @Published var buttonTitle: String
    
    init(
        title: String,
        recoveryPhrase: RecoveryPhraseState,
        copyValidationTitle: String,
        hasCopiedPhrase: Bool,
        buttonTitle: String
    ) {
        self.title = title
        self.recoveryPhrase = recoveryPhrase
        self.copyValidationTitle = copyValidationTitle
        self.hasCopiedPhrase = hasCopiedPhrase
        self.buttonTitle = buttonTitle
    }
}
