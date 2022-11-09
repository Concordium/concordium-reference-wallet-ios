//
//  SeedIdentityStatusPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 05/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

protocol SeedIdentityStatusPresenterDelegate: AnyObject {
    func seedIdentityStatusDidFinish(with identity: IdentityDataType)
    func seedNewIdentityStatusDidFinish(with identity: IdentityDataType)
    func makeNewIdentityRequestAfterSettingUpWallet()
    func makeNewAccount(with identity: IdentityDataType)
}

class SeedIdentityStatusPresenter: SwiftUIPresenter<SeedIdentityStatusViewModel> {
    private weak var delegate: SeedIdentityStatusPresenterDelegate?
    
    private var identity: IdentityDataType
    private let identititesService: SeedIdentitiesService
    
    private var isNewIdentityAfterSettingUpTheWallet: Bool
    
    init(
        identity: IdentityDataType,
        identitiesService: SeedIdentitiesService,
        delegate: SeedIdentityStatusPresenterDelegate, isNewIdentityAfterSettingUpTheWallet: Bool = false
    ) {
        self.identity = identity
        self.identititesService = identitiesService
        self.delegate = delegate
        self.isNewIdentityAfterSettingUpTheWallet = isNewIdentityAfterSettingUpTheWallet
        let identityViewModel = IdentityCard.ViewModel()
        identityViewModel.update(with: identity)
        
        super.init(
            viewModel: .init(
                title: "identities.seed.status.title".localized,
                body: isNewIdentityAfterSettingUpTheWallet ? "newidentities.seed.status.body".localized : "identities.seed.status.body".localized,
                identityViewModel: identityViewModel,
                continueLabel: isNewIdentityAfterSettingUpTheWallet ? "newidentities.seed.status.continue".localized : "identities.seed.status.continue".localized,
                isNewIdentityAfterSettingUpTheWallet: isNewIdentityAfterSettingUpTheWallet
            )
        )
        
        viewModel.navigationTitle = isNewIdentityAfterSettingUpTheWallet ? "newidentities.seed.status.navigationtitle".localized : "identities.seed.status.navigationtitle".localized
        
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
            if isNewIdentityAfterSettingUpTheWallet {
                viewModel.isIdentityConfirmed = true
            }
        case .failed:
            if isNewIdentityAfterSettingUpTheWallet {
                viewModel.identityRejectionError = IdentityRejectionError(description: identity.identityCreationError)
            }
        }
    }
    
    override func receive(event: SeedIdentityStatusEvent) {
        switch event {
        case .finish:
            delegate?.seedIdentityStatusDidFinish(with: identity)
        case .finishNewIdentityAfterSettingUpTheWallet:
            delegate?.seedNewIdentityStatusDidFinish(with: identity)
        case .makeNewIdentityRequest:
            if let delegate = delegate {
                delegate.makeNewIdentityRequestAfterSettingUpWallet()
            }
        case .makeNewAccountRequest:
            if let delegate = delegate {
                delegate.makeNewAccount(with: identity)
            }
        }
    }
}
