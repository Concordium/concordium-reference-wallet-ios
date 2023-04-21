//
//  RecoveryPhraseOnboardingViewModel.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 01/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Combine

enum RecoveryPhraseOnboardingEvent {
    case continueTapped
}

class RecoveryPhraseOnboardingViewModel: PageViewModel<RecoveryPhraseOnboardingEvent> {
    @Published var message: String
    @Published var continueLabel: String
    
    init(
        message: String,
        continueLabel: String
    ) {
        self.message = message
        self.continueLabel = continueLabel
        
        super.init()
    }
}
