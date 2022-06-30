//
//  RecoveryPhraseGettingStartedPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 29/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

protocol RecoveryPhraseGettingStartedPresenterDelegate: AnyObject {
    func setupNewWallet()
    func recoverWallet()
}

class RecoveryPhraseGettingStartedPresenter: SwiftUIPresenter<RecoveryPhraseGettingStartedViewModel> {
    private weak var delegate: RecoveryPhraseGettingStartedPresenterDelegate?
    
    init(delegate: RecoveryPhraseGettingStartedPresenterDelegate) {
        self.delegate = delegate
        
        let viewModel = RecoveryPhraseGettingStartedViewModel(
            title: "recoveryphrase.gettingstarted.title".localized,
            createNewWalletSection: .init(
                title: "recoveryphrase.gettingstarted.new.title".localized,
                body: "recoveryphrase.gettingstarted.new.body".localized,
                buttonTitle: "recoveryphrase.gettingstarted.new.buttontitle".localized
            ),
            recoverWalletSection: .init(
                title: "recoveryphrase.gettingstarted.recover.title".localized,
                body: "recoveryphrase.gettingstarted.recover.body".localized,
                buttonTitle: "recoveryphrase.gettingstarted.recover.buttontitle".localized
            )
        )
        viewModel.navigationTitle = "recoveryphrase.gettingstarted.navigationtitle".localized
     
        super.init(viewModel: viewModel)
    }
    
    override func receive(event: RecoveryPhraseGettingStartedEvent) {
        switch event {
        case .createNewWallet:
            delegate?.setupNewWallet()
        case .recoverWallet:
            delegate?.recoverWallet()
        }
    }
}
