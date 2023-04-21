//
//  RecoveryPhraseRecoverIntroPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 28/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

protocol RecoveryPhraseRecoverIntroPresenterDelegate: AnyObject {
    func recoverIntroWasFinished()
}

class RecoveryPhraseRecoverIntroPresenter: SwiftUIPresenter<RecoveryPhraseRecoverIntroViewModel> {
    private weak var delegate: RecoveryPhraseRecoverIntroPresenterDelegate?
    
    init(
        delegate: RecoveryPhraseRecoverIntroPresenterDelegate
    ) {
        self.delegate = delegate
        
        super.init(
            viewModel: .init(
                title: "recoveryphrase.recover.intro.title".localized,
                body: "recoveryphrase.recover.intro.body".localized,
                continueLabel: "recoveryphrase.recover.intro.continue".localized
            )
        )
        
        viewModel.navigationTitle = "recoveryphrase.recover.intro.navigationtitle".localized
    }
    
    override func receive(event: RecoveryPhraseRecoverIntroEvent) {
        switch event {
        case .finish:
            delegate?.recoverIntroWasFinished()
        }
    }
}
