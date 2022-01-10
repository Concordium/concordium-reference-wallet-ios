//
//  AccountsCoordinator.swift
//  ConcordiumWallet
//
//  Created by Concordium on 05/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Combine
import Foundation
import UIKit

protocol AccountsCoordinatorDelegate: AnyObject {
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
    
    func showNewTerms() {
        let TermsAndConditionsPresenter = TermsAndConditionsPresenter(delegate: self)
        let vc = TermsAndConditionsFactory.create(with: TermsAndConditionsPresenter)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        navigationController.present(nav, animated: true, completion: nil)
    }
    
    func showExport() {
        let vc = ExportFactory.create(with: ExportPresenter(
            dependencyProvider: ServicesProvider.defaultProvider(),
            requestPasswordDelegate: self,
            delegate: self
        ))
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func showCreateExportPassword() -> AnyPublisher<String, Error> {
        let selectExportPasswordCoordinator = CreateExportPasswordCoordinator(
            navigationController: TransparentNavigationController(),
            dependencyProvider: ServicesProvider.defaultProvider()
        )
        self.childCoordinators.append(selectExportPasswordCoordinator)
        selectExportPasswordCoordinator.navigationController.modalPresentationStyle = .fullScreen
        selectExportPasswordCoordinator.start()
        navigationController.present(selectExportPasswordCoordinator.navigationController, animated: true)
        return selectExportPasswordCoordinator.passwordPublisher.eraseToAnyPublisher()
    }
}

extension AccountsCoordinator: AccountsPresenterDelegate {
    func didSelectMakeBackup() {
        showExport()
    }
    
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
    
    func newTermsAvailable() {
        self.showNewTerms()
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

extension AccountsCoordinator: RequestPasswordDelegate { }

extension AccountsCoordinator: ExportPresenterDelegate {
    func createExportPassword() -> AnyPublisher<String, Error> {
        let cleanup: (Result<String, Error>) -> Future<String, Error> = { [weak self] result in
                    let future = Future<String, Error> { promise in
                        self?.navigationController.dismiss(animated: true) {
                            promise(result)
                        }
                        self?.childCoordinators.removeAll { coordinator in
                            coordinator is CreateExportPasswordCoordinator
                        }
                    }
                    return future
                }
        return showCreateExportPassword()
                .flatMap { cleanup(.success($0)) }
                .catch { cleanup(.failure($0)) }
                .eraseToAnyPublisher()
    }

    func shareExportedFile(url: URL, completion: @escaping () -> Void) {
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
        vc.completionWithItemsHandler = { exportActivityType, completed, _, _ in
            // exportActivityType == nil means that the user pressed the close button on the share sheet
            if completed {
                AppSettings.backupPerformed = true
            }

            if completed || exportActivityType == nil {
                completion()
                self.exportFinished()
            }
        }
        self.navigationController.present(vc, animated: true)
    }
    
    func exportFinished() {
        navigationController.popViewController(animated: true)
    }
}

extension AccountsCoordinator: TermsAndConditionsPresenterDelegate {
    func userTappedAcceptTerms() {
        navigationController.dismiss(animated: true)
    }
}
