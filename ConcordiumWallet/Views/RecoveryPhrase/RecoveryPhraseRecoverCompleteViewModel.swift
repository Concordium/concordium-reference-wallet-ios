//
//  RecoveryPhraseRecoverCompleteViewModel.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 01/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Combine

enum RecoveryPhraseRecoverCompleteEvent {
    case finish
}

class RecoveryPhraseRecoverCompleteViewModel: PageViewModel<RecoveryPhraseRecoverCompleteEvent> {
    @Published var title: String
    @Published var continueLabel: String
    
    init(
        title: String,
        continueLabel: String
    ) {
        self.title = title
        self.continueLabel = continueLabel
    }
}
