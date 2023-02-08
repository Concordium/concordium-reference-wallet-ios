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
//    func reenterRecoveryPhrase()
}

class IdentityRecoveryStatusPresenter: SwiftUIPresenter<IdentityRecoveryStatusViewModel> {
    private let recoveryPhrase: RecoveryPhrase?
    private let recoveryPhraseService: RecoveryPhraseServiceProtocol?
    private var seed: Seed?
    private var pwHash: String?
    private let identitiesService: SeedIdentitiesService
    private let accountsService: SeedAccountsService
    private let keychain: KeychainWrapperProtocol
    private weak var delegate: IdentityRecoveryStatusPresenterDelegate?
    
    init(
        recoveryPhrase: RecoveryPhrase?,
        recoveryPhraseService: RecoveryPhraseServiceProtocol?,
        seed: Seed? = nil,
        pwHash: String? = nil,
        identitiesService: SeedIdentitiesService,
        accountsService: SeedAccountsService,
        keychain: KeychainWrapperProtocol,
        delegate: IdentityRecoveryStatusPresenterDelegate
    ) {
        self.recoveryPhrase = recoveryPhrase
        self.recoveryPhraseService = recoveryPhraseService
        self.seed = seed
        self.pwHash = pwHash
        self.identitiesService = identitiesService
        self.accountsService = accountsService
        self.keychain = keychain
        self.delegate = delegate
        
        super.init(
            viewModel: .init(
                status: .fetching,
                title: "identityrecovery.status.title.fetching".localized,
                message: "identityrecovery.status.message.fetching".localized,
                continueLongLabel: "identityrecovery.status.continuelong".localized,
                continueLabel: "identityrecovery.status.continue".localized,
                tryAgain: "identityrecovery.status.tryagain".localized
//                changeRecoveryPhrase: "identityrecovery.status.changerecoveryphrase".localized
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
//        case .changeRecoveryPhrase:
//            if case .emptyResponse = viewModel.status {
//                delegate?.reenterRecoveryPhrase()
//            }
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
                
                if self.pwHash == nil {
                    self.pwHash = try await delegate.requestUserPassword(keychain: keychain)
                }
                
                if self.seed == nil && self.recoveryPhrase != nil && self.recoveryPhraseService != nil {
                    self.seed = try await self.recoveryPhraseService!.store(
                        recoveryPhrase: self.recoveryPhrase!,
                        with: self.pwHash!
                    )
                }
                
                let (identities, failedIdentityProviders) = try await self.identitiesService.recoverIdentities(
                    with: self.seed!
                )
                
                let accounts = try await self.accountsService.recoverAccounts(
                    for: identities,
                    seed: self.seed!,
                    pwHash: self.pwHash!
                )
                
                let storageManager: StorageManager = StorageManager(keychain: keychain)
                
                var recoveredIdentities: [IdentityDataType] = []
                
                for identity in identities {
                    if storageManager.getIdentity(matchingSeedIdentityObject: identity.seedIdentityObject!) == nil {
                        recoveredIdentities.append(identity)
                    } else {
                        var identityHasRecoveredAccount = false
                        
                        for account in accounts {
                            if account.identity!.id == identity.id {
                                identityHasRecoveredAccount = true
                            }
                        }
                        
                        if identityHasRecoveredAccount {
                            recoveredIdentities.append(identity)
                        }
                    }
                }
                
                self.handleIdentities(recoveredIdentities, accounts: accounts, failedIdentitiesProviders: failedIdentityProviders)
            } catch {
//                self.viewModel.status = .failed
//                self.viewModel.showAlert(
//                    .alert(
//                        .init(
//                            title: "identityrecovery.status.requestfailed.title".localized,
//                            message: "identityrecovery.status.requestfailed.message".localized,
//                            actions: [
//                                .init(
//                                    name: "identityrecovery.status.requestfailed.retry".localized,
//                                    completion: nil,
//                                    style: .default
//                                ),
//                                .init(
//                                    name: "identityrecovery.status.requestfailed.later".localized,
//                                    completion: nil,
//                                    style: .default
//                                )
//                            ]
//                        )
//                    )
//                )
            }
            self.viewModel.hideLoading()
        }
    }
    
    private func handleIdentities(_ identities: [IdentityDataType], accounts: [AccountDataType], failedIdentitiesProviders: [String]) {
        if !failedIdentitiesProviders.isEmpty {
            var failedIdentitiesProvidersString = ""
            for identityProvider in failedIdentitiesProviders {
                failedIdentitiesProvidersString += "\n* \(identityProvider)"
            }
            
            viewModel.status = .partial(identities, accounts, failedIdentitiesProviders)
            viewModel.title = "identityrecovery.status.title.partial".localized
            viewModel.message = recoveryPhrase != nil ? String(format: "identityrecovery.status.message.partial".localized, failedIdentitiesProvidersString) : String(format: "identitynewrecovery.status.message.partial".localized, failedIdentitiesProvidersString)
        } else if identities.isEmpty {
            viewModel.status = .emptyResponse
            viewModel.title = "identityrecovery.status.title.emptyResponse".localized
            viewModel.message = "identityrecovery.status.message.emptyResponse".localized
        } else {
            viewModel.status = .success(identities, accounts)
            viewModel.title = "identityrecovery.status.title.success".localized
            viewModel.message = recoveryPhrase != nil ? "identityrecovery.status.message.success".localized : "identitynewrecovery.status.message.success".localized
        }
    }
}
