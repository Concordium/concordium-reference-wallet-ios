//
//  IdentityChooseForAccountCreationPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/19/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

// MARK: -
// MARK: Presenter Delegate
protocol IdentityChoosePresenterDelegate: AnyObject {
    func identitySelected(for: AccountDataType)
    func chooseIdentityPresenterCancelled(_ chooseIdentityPresenter: IdentityChoosePresenter)
}

class IdentityChoosePresenter: IdentityGeneralPresenter, ShowToast {
    
    override func getTitle() -> String {
        "identityData.title".localized
    }
    
    weak var delegate: IdentityChoosePresenterDelegate?
    private var dependencyProvider: AccountsFlowCoordinatorDependencyProvider
    var account: AccountDataType

    init(dependencyProvider: AccountsFlowCoordinatorDependencyProvider, delegate: IdentityChoosePresenterDelegate? = nil, nickname: String) {
        account = AccountDataTypeFactory.create()
        account.name = nickname
        account.encryptedBalanceStatus = .decrypted
        self.dependencyProvider = dependencyProvider
        self.delegate = delegate
    }

    override func viewWillAppear() {
        identities = dependencyProvider.storageManager().getConfirmedIdentities()
    }

    override func userSelectedIdentity(index: Int) {
        if index < viewModels.count {
            let identity: IdentityDataType = identities[index]
            if identity.accountsCreated >= identity.identityObject?.attributeList.maxAccounts ?? 0 {
                showToast(withMessage: "createAccount.tooManyAccounts".localized, time: 2.75)
                return
            }
            account.identity = identity
            delegate?.identitySelected(for: account)
        }
    }
    
    override func cancel() {
        delegate?.chooseIdentityPresenterCancelled(self)
    }
}
