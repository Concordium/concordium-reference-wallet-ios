//
//  RecoveryPhraseSetupCompletePresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 27/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

protocol RecoveryPhraseSetupCompletePresenterDelegate: AnyObject {
    func recoveryPhraseSetupFinished(with recoveryPhrase: RecoveryPhrase)
}

class RecoveryPhraseSetupCompletePresenter: SwiftUIPresenter<RecoveryPhraseSetupCompleteViewModel> {
    private let recoveryPhrase: RecoveryPhrase
    private weak var delegate: RecoveryPhraseSetupCompletePresenterDelegate?
    
    init(
        recoveryPhrase: RecoveryPhrase,
        delegate: RecoveryPhraseSetupCompletePresenterDelegate
    ) {
        self.recoveryPhrase = recoveryPhrase
        self.delegate = delegate
        
        super.init(
            viewModel: .init(
                title: "recoveryphrase.setupcomplete.title".localized,
                continueLabel: "recoveryphrase.setupcomplete.continue".localized
            )
        )
        
        viewModel.navigationTitle = "recoveryphrase.setupcomplete.navigationtitle".localized
    }
    
    override func receive(event: RecoveryPhraseSetupCompleteEvent) {
        switch event {
        case .finish:
            delegate?.recoveryPhraseSetupFinished(with: recoveryPhrase)
        }
    }
}
