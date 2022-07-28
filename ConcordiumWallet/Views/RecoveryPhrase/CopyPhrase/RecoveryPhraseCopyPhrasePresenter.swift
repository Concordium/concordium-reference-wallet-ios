//
//  RecoveryPhraseCopyPhrasePresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 30/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

protocol RecoveryPhraseCopyPhrasePresenterDelegate: AnyObject {
    func finishedCopyingPhrase(with recoveryPhrase: RecoveryPhrase)
}

class RecoveryPhraseCopyPhrasePresenter: SwiftUIPresenter<RecoveryPhraseCopyPhraseViewModel> {
    private let recoveryPhrase: RecoveryPhrase
    
    private weak var delegate: RecoveryPhraseCopyPhrasePresenterDelegate?
    
    init(
        recoveryPhrase: RecoveryPhrase,
        delegate: RecoveryPhraseCopyPhrasePresenterDelegate
    ) {
        self.recoveryPhrase = recoveryPhrase
        self.delegate = delegate
        
        super.init(
            viewModel: .init(
                title: "recoveryphrase.copyphrase.title".localized,
                recoveryPhrase: .hidden(message: "recoveryphrase.copyphrase.revealmessage".localized),
                copyValidationTitle: "recoveryphrase.copyphrase.validationmessage".localized,
                hasCopiedPhrase: false,
                buttonTitle: "recoveryphrase.copyphrase.continue".localized
            )
        )
        
        viewModel.navigationTitle = "recoveryphrase.copyphrase.navigationtitle".localized
    }
    
    override func receive(event: RecoveryPhraseCopyPhraseEvent) {
        switch event {
        case .showPhrase:
            viewModel.recoveryPhrase = .shown(recoveryPhrase: recoveryPhrase)
        case .confirmBoxTapped:
            if case .shown = viewModel.recoveryPhrase {
                viewModel.hasCopiedPhrase.toggle()
            }
        case .continueTapped:
            if viewModel.hasCopiedPhrase {
                delegate?.finishedCopyingPhrase(with: recoveryPhrase)
            }
        }
    }
}
