//
//  RecoveryPhraseConfirmPhrasePresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 25/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

protocol RecoveryPhraseConfirmPhrasePresenterDelegate: AnyObject {
    func recoveryPhraseHasBeenConfirmed(_ recoveryPhrase: RecoveryPhrase)
}

class RecoveryPhraseConfirmPhrasePresenter: SwiftUIPresenter<RecoveryPhraseConfirmPhraseViewModel> {
    private let recoveryPhrase: RecoveryPhrase
    
    private weak var delegate: RecoveryPhraseConfirmPhrasePresenterDelegate?
    
    init(
        recoveryPhrase: RecoveryPhrase,
        recoveryPhraseService: RecoveryPhraseServiceProtocol,
        delegate: RecoveryPhraseConfirmPhrasePresenterDelegate
    ) {
        self.recoveryPhrase = recoveryPhrase
        self.delegate = delegate
        
        super.init(
            viewModel: .init(
                title: "recoveryphrase.confirmphrase.title".localized,
                suggestions: recoveryPhraseService.generateSuggestions(from: recoveryPhrase, maxNumberOfSuggestions: 4),
                selectedWords: Array(repeating: "", count: recoveryPhrase.count)
            )
        )
        
        viewModel.navigationTitle = "recoveryphrase.confirmphrase.navigationtitle".localized
    }
    
    override func receive(event: RecoveryPhraseConfirmPhraseEvent) {
        switch event {
        case .selectWord(let index, let word):
            if index < viewModel.selectedWords.count {
                viewModel.selectedWords[index] = word
            }
            if viewModel.selectedWords.allSatisfy({ !$0.isEmpty }) {
                if recoveryPhrase.verify(words: viewModel.selectedWords) {
                    delegate?.recoveryPhraseHasBeenConfirmed(recoveryPhrase)
                } else {
                    // TODO: Change for testing purposes
//                    delegate?.recoveryPhraseHasBeenConfirmed(recoveryPhrase)
                    viewModel.error = "recoveryphrase.confirmphrase.validationerror".localized
                }
            }
        }
    }
}
