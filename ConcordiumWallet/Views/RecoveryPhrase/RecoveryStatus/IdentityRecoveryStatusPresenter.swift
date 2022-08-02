//
//  IdentityRecoveryStatusPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 01/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

protocol IdentityRecoveryStatusPresenterDelegate: AnyObject {
    func identityRecoveryCompleted()
    func reenterRecoveryPhrase()
}

class IdentityRecoveryStatusPresenter: SwiftUIPresenter<IdentityRecoveryStatusViewModel> {
    private let recoveryPhrase: RecoveryPhrase
    private let recoveryPhraseService: RecoveryPhraseServiceProtocol
    private weak var delegate: IdentityRecoveryStatusPresenterDelegate?
    
    init(
        recoveryPhrase: RecoveryPhrase,
        recoveryPhraseService: RecoveryPhraseServiceProtocol,
        delegate: IdentityRecoveryStatusPresenterDelegate
    ) {
        self.recoveryPhrase = recoveryPhrase
        self.recoveryPhraseService = recoveryPhraseService
        self.delegate = delegate
        
        super.init(
            viewModel: .init(
                status: .fetching,
                title: "identityrecovery.status.title.fetching".localized,
                message: "identityrecovery.status.message.fetching".localized,
                continueLabel: "identityrecovery.status.continue".localized,
                tryAgain: "identityrecovery.status.tryagain".localized,
                changeRecoveryPhrase: "identityrecovery.status.changerecoveryphrase".localized
            )
        )
        
        viewModel.navigationTitle = "identityrecovery.status.navigationtitle".localized
        
        fetchIdentities()
    }
    
    override func receive(event: IdentityRecoveryStatusEvent) {
        switch event {
        case .fetchIdentities:
            if !viewModel.status.isFecthing {
                viewModel.status = .fetching
                
                fetchIdentities()
            }
        case .changeRecoveryPhrase:
            if case .emptyResponse = viewModel.status {
                delegate?.reenterRecoveryPhrase()
            }
        case .finish:
            if !viewModel.status.isFecthing {
                delegate?.identityRecoveryCompleted()
            }
        }
    }
    
    private func fetchIdentities() {
        recoveryPhraseService.recoverIdentities(for: recoveryPhrase)
            .sink(receiveError: { [weak self] _ in
                self?.viewModel.status = .failed
                self?.viewModel.alertPublisher.send(
                    .alert(
                        .init(
                            title: "identityrecovery.status.requestfailed.title".localized,
                            message: "identityrecovery.status.requestfailed.message".localized,
                            actions: [
                                .init(
                                    name: "identityrecovery.status.requestfailed.retry".localized,
                                    completion: nil,
                                    style: .default
                                ),
                                .init(
                                    name: "identityrecovery.status.requestfailed.later".localized,
                                    completion: nil,
                                    style: .default
                                )
                            ]
                        )
                    )
                )
            }, receiveValue: { [weak self] identities in
                self?.handleIdentities(identities)
            })
            .store(in: &cancellables)
    }
    
    private func handleIdentities(_ identities: [IdentityDataType]) {
        if identities.isEmpty {
            viewModel.status = .emptyResponse
            viewModel.title = "identityrecovery.status.title.failed".localized
            viewModel.message = "identityrecovery.status.message.failed".localized
        } else {
            viewModel.status = .success(identities)
            viewModel.title = "identityrecovery.status.title.success".localized
            viewModel.message = "identityrecovery.status.message.success".localized
        }
    }
}
