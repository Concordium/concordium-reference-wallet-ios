//
//  RecoveryPhraseRecoverCompletePresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 01/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

protocol RecoveryPhraseRecoverCompletePresenterDelegate: AnyObject {
    func completeRecovery(with recoveryPhrase: RecoveryPhrase)
}

class RecoveryPhraseRecoverCompletePresenter: SwiftUIPresenter<RecoveryPhraseRecoverCompleteViewModel> {
    private let recoveryPhrase: RecoveryPhrase
    private weak var delegate: RecoveryPhraseRecoverCompletePresenterDelegate?
    
    init(
        recoveryPhrase: RecoveryPhrase,
        delegate: RecoveryPhraseRecoverCompletePresenterDelegate
    ) {
        self.recoveryPhrase = recoveryPhrase
        self.delegate = delegate
        
        super.init(
            viewModel: .init(
                title: "recoveryphrase.recover.complete.title".localized,
                continueLabel: "recoveryphrase.recover.complete.continue".localized
            )
        )
        
        viewModel.navigationTitle = "recoveryphrase.recover.complete.navigationtitle".localized
    }
    
    override func receive(event: RecoveryPhraseRecoverCompleteEvent) {
        switch event {
        case .finish:
            delegate?.completeRecovery(with: recoveryPhrase)
        }
    }
}
