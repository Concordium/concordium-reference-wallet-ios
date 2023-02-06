//
//  SubmittedSeedAccountPresenter.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 7.11.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

protocol SubmittedSeedAccountPresenterDelegate: AnyObject {
    func accountHasBeenFinished(for identity: IdentityDataType)
}

class SubmittedSeedAccountPresenter: SwiftUIPresenter<SubmittedSeedAccountViewModel> {
    private weak var delegate: SubmittedSeedAccountPresenterDelegate?
    
    private var identity: IdentityDataType
    private let identititesService: SeedIdentitiesService
    private let accountsService: SeedAccountsService
    
    init(
        identity: IdentityDataType,
        identitiesService: SeedIdentitiesService,
        accountsService: SeedAccountsService,
        delegate: SubmittedSeedAccountPresenterDelegate
    ) {
        self.identity = identity
        self.identititesService = identitiesService
        self.accountsService = accountsService
        self.delegate = delegate
        
        let identityViewModel = IdentityCard.ViewModel()
        identityViewModel.update(with: identity)
        
        super.init(
            viewModel: .init(
                title: "submittedaccount.title".localized,
                body: "submittedaccount.body".localized,
                finishAccount: "submittedaccount.finish".localized,
                identityViewModel: identityViewModel,
                accountViewModel: .init(
                    state: .notAvailable,
                    accountIndex: identity.accountsCreated,
                    identityNickname: identity.nickname,
                    totalLabel: "identities.seed.submitaccount.total".localized,
                    totalAmount: .zero,
                    atDisposalLabel: "identities.seed.submitaccount.atdisposal".localized,
                    atDisposalAmount: .zero
                )
            )
        )
        
        viewModel.navigationTitle = "submittedaccount.navigationtitle".localized
        
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
            break
        }
    }
    
    override func receive(event: SubmittedSeedAccountEvent) {
        switch event {
        case .finishAccount:
            delegate?.accountHasBeenFinished(for: identity)
        }
    }
}
