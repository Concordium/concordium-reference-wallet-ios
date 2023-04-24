//
//  RecoveryPhraseRecoverIntroViewModel.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 28/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Combine

enum RecoveryPhraseRecoverIntroEvent {
    case finish
}

class RecoveryPhraseRecoverIntroViewModel: PageViewModel<RecoveryPhraseRecoverIntroEvent> {
    @Published var title: String
    @Published var body: String
    @Published var continueLabel: String
    
    init(
        title: String,
        body: String,
        continueLabel: String
    ) {
        self.title = title
        self.body = body
        self.continueLabel = continueLabel
    }
}
