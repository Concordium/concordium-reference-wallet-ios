//
//  InitialAccountsCoordinator.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 11/11/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

protocol InitialAccountsCoordinatorDelegate: class {
    func finishedCreatingInitialIdentity()
}



class InitialAccountsCoordinator: Coordinator, ShowError {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    weak var delegate: InitialAccountsCoordinatorDelegate?

    private var identitiesProvider: IdentitiesFlowCoordinatorDependencyProvider
    private var accountsProvider: AccountsFlowCoordinatorDependencyProvider

    init(navigationController: UINavigationController,
         parentCoordinator: InitialAccountsCoordinatorDelegate,
         identitiesProvider: IdentitiesFlowCoordinatorDependencyProvider,
         accountsProvider: AccountsFlowCoordinatorDependencyProvider) {
        self.navigationController = navigationController
        self.identitiesProvider = identitiesProvider
        self.accountsProvider = accountsProvider
        self.delegate = parentCoordinator
    }

    func start() {
        showGettingStarted()
    }

    
    func showGettingStarted() {
        let gettingStartedPresenter = GettingStartedPresenter(delegate: self)
        let vc = GettingStartedFactory.create(with: gettingStartedPresenter)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showCreateNewAccount(withDefaultValuesFrom account: AccountDataType? = nil) {
        let createNewAccountPresenter = CreateNicknamePresenter(withDefaultName: account?.name,
                                                                delegate: self,
                                                                properties: CreateInitialAccountNicknameProperties())
        let vc = CreateNicknameFactory.create(with: createNewAccountPresenter)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showCreateNewIdentity() {
        let createIdentityCoordinator = CreateIdentityCoordinator(navigationController: navigationController,
                                                                  dependencyProvider: identitiesProvider,
                                                                  parentCoordinator: self)
        childCoordinators.append(createIdentityCoordinator)
        createIdentityCoordinator.startWithIdentity()
//        navigationController.present(createIdentityCoordinator.navigationController, animated: true, completion: nil)
    }
    
    func showInitialAccountInfo() {
        let initialAccountPresenter = InitialAccountInfoPresenter(delegate: self, type: .firstAccount)
        let vc = InitialAccountInfoFactory.create(with: initialAccountPresenter)
        vc.title = initialAccountPresenter.type.getViewModel().title
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showImportInfo() {
        let initialAccountPresenter = InitialAccountInfoPresenter(delegate: self, type: .importAccount)
        let vc = InitialAccountInfoFactory.create(with: initialAccountPresenter)
        vc.title = initialAccountPresenter.type.getViewModel().title
        navigationController.pushViewController(vc, animated: true)
    }
}

extension InitialAccountsCoordinator: CreateNicknamePresenterDelegate {
    func createNicknamePresenterCancelled(_ createNicknamePresenter: CreateNicknamePresenter) {
        navigationController.popToRootViewController(animated: true)
    }

    func createNicknamePresenter(_ createNicknamePresenter: CreateNicknamePresenter, didCreateName nickname: String, properties: CreateNicknameProperties) {
        var account = AccountDataTypeFactory.create()
        account.name = nickname
        account.transactionStatus = .committed
        account.encryptedBalanceStatus = .decrypted
        do {
            cleanupUnfinishedAccounts()
            try accountsProvider.storageManager().storeAccount(account)
        } catch {
            Logger.error(error)
            self.showErrorAlert(.genericError(reason: error))
        }
        
        showCreateNewIdentity()
    }
    
    private func cleanupUnfinishedAccounts() {
        let unfinishedAccounts = accountsProvider.storageManager().getAccounts().filter { $0.address == ""}
        for account in unfinishedAccounts {
            accountsProvider.storageManager().removeAccount(account: account)
        }
    }
}

extension InitialAccountsCoordinator: CreateNewIdentityDelegate {
    func createNewIdentityFinished() {
        self.navigationController.dismiss(animated: true)
        self.childCoordinators.removeAll {$0 is CreateIdentityCoordinator}
        self.delegate?.finishedCreatingInitialIdentity()
    }
    
    func createNewIdentityCancelled() {
        navigationController.popToRootViewController(animated: true)
        self.childCoordinators.removeAll {$0 is CreateIdentityCoordinator}
    }
}

extension InitialAccountsCoordinator: GettingStartedPresenterDelegate {
    func userTappedCreateAccount() {
        showInitialAccountInfo()
    }
    func userTappedImport() {
        showImportInfo()
    }
}

extension InitialAccountsCoordinator: InitialAccountInfoPresenterDelegate {
    func userTappedClose() {
        navigationController.popToRootViewController(animated: true)
    }
    
    func userTappedOK(withType type: InitialAccountInfoType) {
        switch type {
        case .firstAccount:
            showCreateNewAccount()
        case .importAccount:
            navigationController.popViewController(animated: true)
        case .newAccount:
            break //no action for new account - we shouldn't reach it in this flow
        case .firstScreen:
            break //no action for new account - we shouldn't reach it in this flow
        }
    }
}
