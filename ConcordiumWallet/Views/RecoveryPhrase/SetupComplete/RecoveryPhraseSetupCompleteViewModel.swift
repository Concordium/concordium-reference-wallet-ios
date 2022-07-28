//
//  RecoveryPhraseSetupCompleteViewModel.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 27/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Combine

enum RecoveryPhraseSetupCompleteEvent {
    case finish
}

class RecoveryPhraseSetupCompleteViewModel: PageViewModel<RecoveryPhraseSetupCompleteEvent> {
    @Published var title: String
    @Published var continueLabel: String
    
    init(title: String, continueLabel: String) {
        self.title = title
        self.continueLabel = continueLabel
    }
}
