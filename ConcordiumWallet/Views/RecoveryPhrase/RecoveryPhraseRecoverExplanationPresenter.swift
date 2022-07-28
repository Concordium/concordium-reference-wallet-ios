//
//  RecoveryPhraseRecoverExplanationPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 28/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

protocol RecoveryPhraseRecoverExplanationPresenterDelegate: AnyObject {
    func recoverExplanationWasFinished()
}

class RecoveryPhraseRecoverExplanationPresenter: SwiftUIPresenter<RecoveryPhraseRecoverExplanationViewModel> {
    private weak var delegate: RecoveryPhraseRecoverExplanationPresenterDelegate?
    
    init(delegate: RecoveryPhraseRecoverExplanationPresenterDelegate) {
        self.delegate = delegate
        
        super.init(viewModel: .init())
        
        viewModel.navigationTitle = "recoveryphrase.recover.explanation.navigationtitle".localized
    }
    
    override func receive(event: RecoveryPhraseRecoverExplanationEvent) {
        switch event {
        case .finish:
            delegate?.recoverExplanationWasFinished()
        }
    }
}
