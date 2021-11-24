//
//  IdentitiesPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 11/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import Combine

// MARK: -
// MARK: Presenter Delegate
protocol IdentitiesPresenterDelegate: AnyObject {
    func identitySelected(identity: IdentityDataType)
    func createIdentitySelected()
    func noValidIdentitiesAvailable()
    func tryAgainIdentity()
}

class IdentitiesPresenter: IdentityGeneralPresenter {
   
    override func getTitle() -> String {
         "identities_tab_title".localized
    }
    
    weak var delegate: IdentitiesPresenterDelegate?
    private var dependencyProvider: IdentitiesFlowCoordinatorDependencyProvider
    private var cancellables: [AnyCancellable] = []

    init(dependencyProvider: IdentitiesFlowCoordinatorDependencyProvider, delegate: IdentitiesPresenterDelegate? = nil) {
        self.dependencyProvider = dependencyProvider
        self.delegate = delegate
    }
    
    override func viewWillAppear() {
        identities = dependencyProvider.storageManager().getIdentities()
        refreshPendingIdentities()
    }

    override func refresh() {
        refreshPendingIdentities()
    }

    private func refreshPendingIdentities() {
        dependencyProvider.identitiesService()
                .updatePendingIdentities()
                .sink(
                        receiveError: { error in
                            Logger.error("Error updating identities: \(error)")
                            self.identities = self.dependencyProvider.storageManager().getIdentities()
                        },
                        receiveValue: { _ in
                            self.identities = self.dependencyProvider.storageManager().getIdentities()
                            self.checkForIdentityFailed()
                        }).store(in: &cancellables)
    }
    
    private func checkForIdentityFailed() {
        let failedIdentities = identities.filter { $0.state == .failed }

        for identity in failedIdentities {
            guard let reference = identity.hashedIpStatusUrl else {
                continue
            }
            
            // if there is an account associated with the identity, we delete the account and show the error
            if let account = dependencyProvider.storageManager().getAccounts(for: identity).first {
                dependencyProvider.storageManager().removeAccount(account: account)
                let identityProviderName = identity.identityProviderName ?? ""
                let identityProviderSupport = identity.identityProvider?.support ?? ""
                view?.showIdentityFailed(identityProviderName: identityProviderName,
                                         identityProviderSupportEmail: identityProviderSupport,
                                         reference: reference) { [weak self] in
                    self?.delegate?.tryAgainIdentity()
                }
                break // we break here because if there are more accounts that failed, we want to show that later on
            }
        }
    }
    
    private func cleanIdentitiesAndAccounts() {
        let accounts = dependencyProvider.storageManager().getAccounts().filter { $0.transactionStatus == SubmissionStatusEnum.absent }
        for account in accounts {
            dependencyProvider.storageManager().removeAccount(account: account)
        }
        let identities = dependencyProvider.storageManager().getIdentities().filter { $0.state == .failed }
        for identity in identities {
            dependencyProvider.storageManager().removeIdentity(identity)
        }
    }

    override func createIdentitySelected() {
        self.delegate?.createIdentitySelected()
    }

    override func userSelectedIdentity(index: Int) {
        if index < viewModels.count {
            delegate?.identitySelected(identity: identities[index])
        }
    }
}
