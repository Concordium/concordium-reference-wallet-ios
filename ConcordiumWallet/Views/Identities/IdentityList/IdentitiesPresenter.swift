//
//  IdentitiesPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 11/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import Combine
import UIKit

// MARK: -
// MARK: Presenter Delegate
protocol IdentitiesPresenterDelegate: AnyObject {
    func identitySelected(identity: IdentityDataType)
    func createIdentitySelected()
    func noValidIdentitiesAvailable()
    func tryAgainIdentity()
    func finishedPresentingIdentities()
    func preventIdentityCreationAlert()
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
    
    deinit {
        self.delegate?.finishedPresentingIdentities()
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
                // if no ip support email is present, we use Concordium's
                let identityProviderSupport = identity.identityProvider?.support ?? AppConstants.Support.concordiumSupportMail
                view?.showIdentityFailed(identityProviderName: identityProviderName,
                                         identityProviderSupportEmail: identityProviderSupport,
                                         reference: reference) { [weak self] chosenAlertOption in
                    switch chosenAlertOption {
                    case .tryAgain:
                        self?.delegate?.tryAgainIdentity()
                    case .support, .copy, .cancel:
                        // no need to refresh because the identities are not updated
                        break
                    }
                }
                break // we break here because if there are more accounts that failed, we want to show that later on
            }
        }
    }

    override func createIdentitySelected() {
        self.delegate?.preventIdentityCreationAlert()
    }
    
//    override func createIdentitySelected() {
//        guard !identities.contains(where: { $0.state == .pending }) else {
//            view?.showAlert(with: AlertOptions(
//                title: nil,
//                message: "identityCreation.hasPending".localized,
//                actions: [
//                    AlertAction(name: "OK".localized, completion: nil, style: .default)
//                ]
//            ))
//
//            return
//        }
//
//        self.delegate?.createIdentitySelected()
//    }


    override func userSelectedIdentity(index: Int) {
        if index < viewModels.count {
            delegate?.identitySelected(identity: identities[index])
        }
    }
}
