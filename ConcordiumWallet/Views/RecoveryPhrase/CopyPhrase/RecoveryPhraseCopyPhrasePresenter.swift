//
//  RecoveryPhraseCopyPhrasePresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 30/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

protocol RecoveryPhraseCopyPhrasePresenterDelegate: AnyObject {
    func finishedCopyingPhrase()
}

class RecoveryPhraseCopyPhrasePresenter: SwiftUIPresenter<RecoveryPhraseCopyPhraseViewModel> {
    private let words: [String]
    
    private weak var delegate: RecoveryPhraseCopyPhrasePresenterDelegate?
    
    init(
        words: [String],
        delegate: RecoveryPhraseCopyPhrasePresenterDelegate
    ) {
        self.words = words
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
        
        viewModel.navigationTitle = String(format: "recoveryphrase.signuptitle".localized, 1, "recoveryphrase.copyphrase.navigationtitle".localized)
    }
    
    override func receive(event: RecoveryPhraseCopyPhraseEvent) {
        switch event {
        case .showPhrase:
            viewModel.recoveryPhrase = .shown(words: words)
        case .confirmBoxTapped:
            viewModel.hasCopiedPhrase.toggle()
        case .continueTapped:
            if viewModel.hasCopiedPhrase {
                delegate?.finishedCopyingPhrase()
            }
        }
    }
}
