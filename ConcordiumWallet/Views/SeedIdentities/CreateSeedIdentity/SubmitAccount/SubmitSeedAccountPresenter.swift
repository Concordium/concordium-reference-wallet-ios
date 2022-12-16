//
//  SubmitSeedAccountPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 10/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

protocol SubmitSeedAccountPresenterDelegate: RequestPasswordDelegate {
    func accountHasBeenSubmitted(_ account: AccountDataType, isNewAccountAfterSettingUpTheWallet: Bool, forIdentity identity: IdentityDataType)
    func makeNewIdentityRequest()
}

class SubmitSeedAccountPresenter: SwiftUIPresenter<SubmitSeedAccountViewModel> {
    private weak var delegate: SubmitSeedAccountPresenterDelegate?
    
    private var identity: IdentityDataType
    private let identititesService: SeedIdentitiesService
    private let accountsService: SeedAccountsService
    private let isNewAccountAfterSettingUpTheWallet: Bool
    
    init(
        identity: IdentityDataType,
        identitiesService: SeedIdentitiesService,
        accountsService: SeedAccountsService,
        delegate: SubmitSeedAccountPresenterDelegate,
        isNewAccountAfterSettingUpTheWallet: Bool = false
    ) {
        self.identity = identity
        self.identititesService = identitiesService
        self.accountsService = accountsService
        self.delegate = delegate
        self.isNewAccountAfterSettingUpTheWallet = isNewAccountAfterSettingUpTheWallet
        
        let identityViewModel = IdentityCard.ViewModel()
        identityViewModel.update(with: identity)
        
        super.init(
            viewModel: .init(
                title: "identities.seed.submitaccount.title".localized,
                body: isNewAccountAfterSettingUpTheWallet ? String(format: "identities.seed.submitnewaccount.body".localized, identity.index + 1) : "identities.seed.submitaccount.body".localized,
                identityViewModel: identityViewModel,
                accountViewModel: .init(
                    state: .notAvailable,
                    accountIndex: identity.accountsCreated,
                    identityIndex: identity.index,
                    totalLabel: "identities.seed.submitaccount.total".localized,
                    totalAmount: .zero,
                    atDisposalLabel: "identities.seed.submitaccount.atdisposal".localized,
                    atDisposalAmount: .zero,
                    submitAccount: "identities.seed.submitaccount.submit".localized
                ),
                isNewAccountAfterSettingUpTheWallet: isNewAccountAfterSettingUpTheWallet
            )
        )
        
        viewModel.navigationTitle = isNewAccountAfterSettingUpTheWallet ? "identities.seed.submitnewaccount.navigationtitle".localized : "identities.seed.submitaccount.navigationtitle".localized
        
        updatePendingIdentity(identity: identity)
    }
    
    private func updatePendingIdentity(
        identity: IdentityDataType,
        after delay: TimeInterval = 0.0
    ) {
        guard identity.state == .pending else {
            receiveUpdatedIdentity(identity: identity)
            return
        }
        
        Task.init {
            try await Task.sleep(nanoseconds: UInt64(delay) * 1_000_000_000)
            
            let updatedIdentity = try await self.identititesService
                .updatePendingSeedIdentity(identity)
            
            self.receiveUpdatedIdentity(identity: updatedIdentity)
        }
    }
    
    private func receiveUpdatedIdentity(identity: IdentityDataType) {
        self.identity = identity
        viewModel.identityViewModel.update(with: identity)
        
        switch identity.state {
        case .pending:
            updatePendingIdentity(identity: identity, after: 5)
        case .confirmed:
            if viewModel.accountViewModel.state == .notAvailable {
                viewModel.accountViewModel.state = .available
            }
        case .failed:
            viewModel.identityRejectionError = IdentityRejectionError(description: identity.identityCreationError)
        }
    }
    
    override func receive(event: SubmitSeedAccountEvent) {
        switch event {
        case .submitAccount:
            if let delegate = delegate, viewModel.accountViewModel.state != .pending {
                viewModel.accountViewModel.state = .pending
                
                Task {
                    do {
                        let account = try await self.accountsService.generateAccount(
                            for: identity,
                            revealedAttributes: [],
                            requestPasswordDelegate: delegate
                        )
                        
                        self.delegate?.accountHasBeenSubmitted(account, isNewAccountAfterSettingUpTheWallet: isNewAccountAfterSettingUpTheWallet, forIdentity: identity)
                    } catch {
                        self.viewModel.alertPublisher.send(.error(ErrorMapper.toViewError(error: error)))
                    }
                }
            }
        case .makeNewIdentityRequest:
            if let delegate = delegate, viewModel.accountViewModel.state == .notAvailable {
                delegate.makeNewIdentityRequest()
            }
        }
    }
}
