//
//  AccountsCoordinator.swift
//  ConcordiumWallet
//
//  Created by Concordium on 05/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

protocol AccountsCoordinatorDelegate: class {
    func createNewIdentity()
    func createNewAccount()
    func noIdentitiesFound()
}

class AccountsCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    weak var delegate: AccountsCoordinatorDelegate?

    private var dependencyProvider: AccountsFlowCoordinatorDependencyProvider

    init(navigationController: UINavigationController, dependencyProvider: AccountsFlowCoordinatorDependencyProvider) {
        self.navigationController = navigationController
        self.dependencyProvider = dependencyProvider
    }

    func start() {
        let vc = AccountsFactory.create(with: AccountsPresenter(dependencyProvider: dependencyProvider, delegate: self))
        vc.tabBarItem = UITabBarItem(title: "accounts_tab_title".localized, image: UIImage(named: "tab_bar_accounts_icon"), tag: 0)
        navigationController.pushViewController(vc, animated: false)
    }

    func showCreateNewAccount(withDefaultValuesFrom account: AccountDataType? = nil) {
        let createAccountCoordinator = CreateAccountCoordinator(navigationController: BaseNavigationController(),
                dependencyProvider: dependencyProvider, parentCoordinator: self)
        childCoordinators.append(createAccountCoordinator)
        createAccountCoordinator.start(withDefaultValuesFrom: account)
        navigationController.present(createAccountCoordinator.navigationController, animated: true, completion: nil)
    }
    
    func showAccountDetails(account: AccountDataType, balanceType: AccountBalanceTypeEnum) {
        let accountDetailsCoordinator = AccountDetailsCoordinator(navigationController: navigationController,
                                                                  dependencyProvider: dependencyProvider,
                                                                  parentCoordinator: self,
                                                                  account: account,
                                                                  balanceType: balanceType)
        
        childCoordinators.append(accountDetailsCoordinator)
        accountDetailsCoordinator.start()
    }
}

extension AccountsCoordinator: AccountsPresenterDelegate {
    func createNewAccount() {
        delegate?.createNewAccount()
    }

    func createNewIdentity() {
        delegate?.createNewIdentity()
    }
    
    func userSelected(account: AccountDataType, balanceType: AccountBalanceTypeEnum) {
        showAccountDetails(account: account, balanceType: balanceType)
    }
    
    func noValidIdentitiesAvailable() {
        self.delegate?.noIdentitiesFound()
    }
    
    func tryAgainIdentity() {
        self.delegate?.createNewIdentity()
    }
}

extension AccountsCoordinator: CreateNewAccountDelegate {
    func createNewAccountFinished() {
        navigationController.dismiss(animated: true)
        childCoordinators.removeAll(where: { $0 is CreateAccountCoordinator })
    }
    
    func createNewAccountCancelled() {
        navigationController.dismiss(animated: true)
        childCoordinators.removeAll(where: { $0 is CreateAccountCoordinator })
    }
}

extension AccountsCoordinator: AccountDetailsDelegate {
    func accountDetailsClosed() {
        navigationController.dismiss(animated: true, completion: nil)
        childCoordinators.removeAll(where: { $0 is AccountDetailsCoordinator })
    }
    
    func retryCreateAccount(failedAccount: AccountDataType) {
        navigationController.popViewController(animated: true)
        showCreateNewAccount(withDefaultValuesFrom: failedAccount)
    }

    func accountRemoved() {
        navigationController.popViewController(animated: true)
    }
}
