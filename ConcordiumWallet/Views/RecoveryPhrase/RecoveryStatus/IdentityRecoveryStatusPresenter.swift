//
//  IdentityRecoveryStatusPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 01/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

protocol IdentityRecoveryStatusPresenterDelegate: RequestPasswordDelegate {
    func identityRecoveryCompleted()
    func reenterRecoveryPhrase()
}

class IdentityRecoveryStatusPresenter: SwiftUIPresenter<IdentityRecoveryStatusViewModel> {
    private let recoveryPhrase: RecoveryPhrase
    private let recoveryPhraseService: RecoveryPhraseServiceProtocol
    private let identitiesService: SeedIdentitiesService
    private let accountsService: SeedAccountsService
    private let keychain: KeychainWrapperProtocol
    private weak var delegate: IdentityRecoveryStatusPresenterDelegate?
    
    init(
        recoveryPhrase: RecoveryPhrase,
        recoveryPhraseService: RecoveryPhraseServiceProtocol,
        identitiesService: SeedIdentitiesService,
        accountsService: SeedAccountsService,
        keychain: KeychainWrapperProtocol,
        delegate: IdentityRecoveryStatusPresenterDelegate
    ) {
        self.recoveryPhrase = recoveryPhrase
        self.recoveryPhraseService = recoveryPhraseService
        self.identitiesService = identitiesService
        self.accountsService = accountsService
        self.keychain = keychain
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
                viewModel.title = "identityrecovery.status.title.fetching".localized
                viewModel.message = "identityrecovery.status.message.fetching".localized
                
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
        guard let delegate = delegate else {
            return
        }
        
        Task {
            do {
                self.viewModel.showLoading()
                let pwHash = try await delegate.requestUserPassword(keychain: keychain)
                
                let seed = try await self.recoveryPhraseService.store(
                    recoveryPhrase: self.recoveryPhrase,
                    with: pwHash
                )
                
                let identities = try await self.identitiesService.recoverIdentities(
                    with: seed
                )
                
                let accounts = try await self.accountsService.recoverAccounts(
                    for: identities,
                    seed: seed,
                    pwHash: pwHash
                )
                
                self.handleIdentities(identities, accounts: accounts)
            } catch {
                self.viewModel.status = .failed
                self.viewModel.showAlert(
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
            }
            self.viewModel.hideLoading()
        }
    }
    
    private func handleIdentities(_ identities: [IdentityDataType], accounts: [AccountDataType]) {
        if identities.isEmpty {
            viewModel.status = .emptyResponse
            viewModel.title = "identityrecovery.status.title.failed".localized
            viewModel.message = "identityrecovery.status.message.failed".localized
        } else {
            viewModel.status = .success(identities, accounts)
            viewModel.title = "identityrecovery.status.title.success".localized
            viewModel.message = "identityrecovery.status.message.success".localized
        }
    }
}
