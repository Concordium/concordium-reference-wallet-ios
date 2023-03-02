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
    case createNewWalletDemoMode
    case recoverWalletDemoMode
    case enterDemoMode
    case cancelDemoMode
}

class RecoveryPhraseGettingStartedViewModel: PageViewModel<RecoveryPhraseGettingStartedEvent> {
    struct Section {
        var title: String
        var body: String
        var buttonTitle: String
    }
    
    @Published var title: String
    @Published var createNewWalletSection: Section
    @Published var recoverWalletSection: Section
    @Published var demoMode: Bool
    
    init(
        title: String,
        createNewWalletSection: Section,
        recoverWalletSection: Section
    ) {
        self.title = title
        self.createNewWalletSection = createNewWalletSection
        self.recoverWalletSection = recoverWalletSection
        self.demoMode = false
    }
}
