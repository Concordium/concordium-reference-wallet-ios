//
//  RecoveryPhraseGettingStartedPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 29/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

protocol RecoveryPhraseGettingStartedPresenterDelegate: RequestPasswordDelegate {
    func setupNewWallet(with recoveryPhrase: [String])
    func recoverWallet()
}

class RecoveryPhraseGettingStartedPresenter: SwiftUIPresenter<RecoveryPhraseGettingStartedViewModel> {
    private weak var delegate: RecoveryPhraseGettingStartedPresenterDelegate?
    private let recoveryPhraseService: RecoveryPhraseServiceProtocol
    
    init(
        recoveryPhraseService: RecoveryPhraseServiceProtocol,
        delegate: RecoveryPhraseGettingStartedPresenterDelegate
    ) {
        self.recoveryPhraseService = recoveryPhraseService
        self.delegate = delegate
        
        super.init(
            viewModel: .init(
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
        )
        
        viewModel.navigationTitle = "recoveryphrase.gettingstarted.navigationtitle".localized
    }
    
    override func receive(event: RecoveryPhraseGettingStartedEvent) {
        switch event {
        case .createNewWallet:
            if let delegate = delegate {
                recoveryPhraseService
                    .generateRecoveryPhrase(requestPasswordDelegate: delegate)
                    .sink(
                        receiveError: {
                            if !GeneralError.isGeneralError(.userCancelled, error: $0) {
                                self.viewModel.alertPublisher.send(.error(ErrorMapper.toViewError(error: $0)))
                            }
                        },
                        receiveValue: { delegate.setupNewWallet(with: $0) }
                    )
                    .store(in: &cancellables)
            }
        case .recoverWallet:
            delegate?.recoverWallet()
        }
    }
}
