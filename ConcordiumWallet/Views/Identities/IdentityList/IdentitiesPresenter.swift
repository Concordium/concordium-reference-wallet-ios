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
protocol IdentitiesPresenterDelegate: class {
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
        let pendingOrConfirmedIdentities = self.identities.filter { $0.state == .confirmed || $0.state == .pending }.count
        if pendingOrConfirmedIdentities == 0 {
            self.view?.showIdentityFailed("identityfailed.first.message".localized, showCancel: false, completion: {
                self.cleanIdentitiesAndAccounts()
                self.delegate?.noValidIdentitiesAvailable()
            })
        } else {
            // we check if any other identities + accounts have failed -> we only show the error is the identity also has an account
            let failedIdentities = self.identities.filter { $0.state == .failed }
            for identity in failedIdentities {
                // if there is an account associated with the identity, we delete the account and show the error
                if let account = dependencyProvider.storageManager().getAccounts(for: identity).first {
                    dependencyProvider.storageManager().removeAccount(account: account)
                    self.view?.showIdentityFailed("identityfailed.message".localized, showCancel: true, completion: {
                        self.dependencyProvider.storageManager().removeIdentity(identity)
                        self.delegate?.tryAgainIdentity()
                        
                    })
                    break //we break here because if there are more accounts that failed, we want to show that later on
                }
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
