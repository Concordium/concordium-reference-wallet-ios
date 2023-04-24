//
//  RecoveryPhraseOnboardingPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 01/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

protocol RecoveryPhraseOnboardingPresenterDelegate: AnyObject {
    func onboardingFinished(with recoveryPhrase: RecoveryPhrase)
}

class RecoveryPhraseOnboardingPresenter: SwiftUIPresenter<RecoveryPhraseOnboardingViewModel> {
    private let recoveryPhrase: RecoveryPhrase
    weak var delegate: RecoveryPhraseOnboardingPresenterDelegate?
    
    init(
        recoveryPhrase: RecoveryPhrase,
        delegate: RecoveryPhraseOnboardingPresenterDelegate
    ) {
        self.recoveryPhrase = recoveryPhrase
        self.delegate = delegate
        
        super.init(
            viewModel: .init(
                message: "recoveryphrase.onboarding.message".localized,
                continueLabel: "recoveryphrase.onboarding.continue".localized
            )
        )
        
        viewModel.navigationTitle = "recoveryphrase.copyphrase.navigationtitle".localized
    }
    
    override func receive(event: RecoveryPhraseOnboardingEvent) {
        switch event {
        case .continueTapped:
            delegate?.onboardingFinished(with: recoveryPhrase)
        }
    }
}
