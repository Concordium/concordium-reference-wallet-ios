//
//  RecoveryPhraseGettingStartedViewModel.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 29/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum RecoveryPhraseGettingStartedEvent {
    case createNewWallet
    case recoverWallet
}

class RecoveryPhraseGettingStartedViewModel: BaseViewModel<RecoveryPhraseGettingStartedEvent> {
    struct Section {
        var title: String
        var body: String
        var buttonTitle: String
    }
    
    @Published var title: String
    @Published var createNewWalletSection: Section
    @Published var recoverWalletSection: Section
    
    init(
        title: String,
        createNewWalletSection: Section,
        recoverWalletSection: Section
    ) {
        self.title = title
        self.createNewWalletSection = createNewWalletSection
        self.recoverWalletSection = recoverWalletSection
    }
}
