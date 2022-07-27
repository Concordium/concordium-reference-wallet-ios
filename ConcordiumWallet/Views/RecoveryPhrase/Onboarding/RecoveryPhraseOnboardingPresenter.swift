//
//  RecoveryPhraseOnboardingPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 01/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

protocol RecoveryPhraseOnboardingPresenterDelegate: AnyObject {
    func onboardingFinished(with recoveryPhrase: [String])
}

class RecoveryPhraseOnboardingPresenter: SwiftUIPresenter<RecoveryPhraseOnboardingViewModel> {
    private let recoveryPhrase: [String]
    weak var delegate: RecoveryPhraseOnboardingPresenterDelegate?
    
    init(
        recoveryPhrase: [String],
        delegate: RecoveryPhraseOnboardingPresenterDelegate
    ) {
        self.recoveryPhrase = recoveryPhrase
        self.delegate = delegate
        
        super.init(viewModel: .init())
        
        viewModel.navigationTitle = "recoveryphrase.copyphrase.navigationtitle".localized
    }
    
    override func receive(event: RecoveryPhraseOnboardingEvent) {
        switch event {
        case .continueTapped:
            delegate?.onboardingFinished(with: recoveryPhrase)
        }
    }
}
