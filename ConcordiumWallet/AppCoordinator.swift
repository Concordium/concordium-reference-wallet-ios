//
//  AppCoordinator.swift
//  ConcordiumWallet
//
//  Created by Johan Rugager Vase on 13/03/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import UIKit
import Combine

class AppCoordinator: NSObject, Coordinator, ShowError, RequestPasswordDelegate {
    var childCoordinators = [Coordinator]()

    var navigationController: UINavigationController
    let defaultProvider = ServicesProvider.defaultProvider()
    private var cancellables: [AnyCancellable] = []
    
    override init() {
        navigationController = TransparentNavigationController()
    }
    
    func start() {
        if isNewAppInstall() {
            clearAppDataFromPreviousInstall()
        }

        UserDefaults.standard.set(true, forKey: "hasRunBefore")
        showLogin()
    }
    
    private func isNewAppInstall() -> Bool {
        let hasRunBefore = UserDefaults.standard.bool(forKey: "hasRunBefore")
        return !hasRunBefore
    }

    private func clearAppDataFromPreviousInstall() {
        let keychain = defaultProvider.keychainWrapper()
        _ = keychain.deleteKeychainItem(withKey: KeychainKeys.password.rawValue)
        _ = keychain.deleteKeychainItem(withKey: KeychainKeys.loginPassword.rawValue)
    }

    private func showLogin() {
        let loginCoordinator = LoginCoordinator(navigationController: navigationController,
                                                parentCoordinator: self,
                                                dependencyProvider: defaultProvider)
        childCoordinators.append(loginCoordinator)
        loginCoordinator.start()
    }

    func showMainTabbar() {
        let identitiesCoordinator = IdentitiesCoordinator(navigationController: BaseNavigationController(),
                                                          dependencyProvider: defaultProvider,
                                                          parentCoordinator: self)
        
        let accountsCoordinator = AccountsCoordinator(navigationController: BaseNavigationController(),
                                                      dependencyProvider: defaultProvider)
        
        let moreCoordinator = MoreCoordinator(navigationController: BaseNavigationController(),
                                              dependencyProvider: defaultProvider)
        
        let tabBarController = MainTabBarController(accountsCoordinator: accountsCoordinator,
                                                    identitiesCoordinator: identitiesCoordinator,
                                                    moreCoordinator: moreCoordinator)
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(tabBarController, animated: true)
    }

    func importWallet(from url: URL) {
        guard defaultProvider.keychainWrapper().passwordCreated() else {
            showErrorAlert(ViewError.simpleError(localizedReason: "import.noUserCreated".localized))
            return
        }
        let importCoordinator = ImportCoordinator(navigationController: TransparentNavigationController(),
                                                  dependencyProvider: defaultProvider,
                                                  parentCoordinator: self,
                                                  importFileUrl: url)
        importCoordinator.navigationController.modalPresentationStyle = .fullScreen
        navigationController.present(importCoordinator.navigationController, animated: true)
        importCoordinator.navigationController.presentationController?.delegate = self
        importCoordinator.start()
        childCoordinators.append(importCoordinator)
    }
    
    func showInitialIdentityCreation() {
        let initiaAccountCreateCoordinator = InitialAccountsCoordinator(navigationController: navigationController,
                                                                        parentCoordinator: self,
                                                                        identitiesProvider: defaultProvider,
                                                                        accountsProvider: defaultProvider)
        initiaAccountCreateCoordinator.start()
        self.navigationController.viewControllers = [self.navigationController.viewControllers.last!]
        childCoordinators.append(initiaAccountCreateCoordinator)
        self.navigationController.setupBaseNavigationControllerStyle()
    }
    
    func logout() {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.dismiss(animated: false) {
                Logger.trace("logout due to application timeout")
                self.childCoordinators.removeAll()
                self.showLogin()
            }
        }
    }
    
    func checkPasswordChangeDidSucceed() {
        
        if AppSettings.passwordChangeInProgress {
            showErrorAlertWithHandler(ViewError.simpleError(localizedReason: "viewError.passwordChangeFailed".localized)) {
                // Proceed with the password change.
                self.requestUserPassword(keychain: self.defaultProvider.keychainWrapper())
                    .sink(receiveError: {[weak self] error in
                        if case GeneralError.userCancelled = error { return }
                        self?.showErrorAlert(ErrorMapper.toViewError(error: error))
                    }, receiveValue: { [weak self] newPassword in
                        
                        self?.defaultProvider.keychainWrapper().getValue(for: KeychainKeys.oldPassword.rawValue, securedByPassword: newPassword)
                            .onSuccess { (oldPassword) in
                                
                                let accounts = self?.defaultProvider.storageManager().getAccounts().filter {
                                    !$0.isReadOnly && $0.transactionStatus == .finalized
                                }
                                
                                if accounts != nil {
                                    for account in accounts! {
                                        let res = self?.defaultProvider.mobileWallet().updatePasscode(for: account,
                                                                                                      oldPwHash: oldPassword,
                                                                                                      newPwHash: newPassword)
                                        switch res {
                                        case .success:
                                            if let name = account.name {
                                                Logger.debug("successfully reencrypted account with name: \(name)")
                                            }
                                        case .failure, .none:
                                            if let name = account.name {
                                                Logger.debug("could not reencrypted account with name: \(name)")
                                            }
                                        }
                                    }
                                }
                            }

                        // Remove old password from keychain and set transaction flag false.
                        try? self?.defaultProvider.keychainWrapper().deleteKeychainItem(withKey: KeychainKeys.oldPassword.rawValue).get()
                        AppSettings.passwordChangeInProgress = false
                    }).store(in: &self.cancellables)
            }
        }
    }
}

extension AppCoordinator: InitialAccountsCoordinatorDelegate {
    func finishedCreatingInitialIdentity() {
        showMainTabbar()
        // Remove InitialAccountsCoordinator from hierarchy.
        self.navigationController.viewControllers = [self.navigationController.viewControllers.last!]
        childCoordinators.removeAll {$0 is InitialAccountsCoordinator}
    }
}

extension AppCoordinator: LoginCoordinatorDelegate {
    func loginDone() {
        let identities = defaultProvider.storageManager().getIdentities()
        
        if identities.filter({$0.state == IdentityState.confirmed || $0.state == IdentityState.pending}).first != nil {
            showMainTabbar()
        } else {
            showInitialIdentityCreation()
        }
        // Remove login from hierarchy.
        self.navigationController.viewControllers = [self.navigationController.viewControllers.last!]
        childCoordinators.removeAll {$0 is LoginCoordinator}

        checkPasswordChangeDidSucceed()
    }

    func passwordSelectionDone() {
        showInitialIdentityCreation()
        // Remove login from hierarchy.
        self.navigationController.viewControllers = [self.navigationController.viewControllers.last!]
        childCoordinators.removeAll {$0 is LoginCoordinator}
    }
}

extension AppCoordinator: ImportCoordinatorDelegate {
    func importCoordinatorDidFinish(_ coordinator: ImportCoordinator) {
        navigationController.dismiss(animated: true)
        childCoordinators.removeAll(where: { $0 is ImportCoordinator })
        
        if childCoordinators.contains(where: { $0 is InitialAccountsCoordinator }) {
            let identities = defaultProvider.storageManager().getIdentities()
            if identities.filter({$0.state == IdentityState.confirmed || $0.state == IdentityState.pending}).first != nil {
                showMainTabbar()
            }
        }
    }

    func importCoordinator(_ coordinator: ImportCoordinator, finishedWithError error: Error) {
        navigationController.dismiss(animated: true)
        childCoordinators.removeAll(where: { $0 is ImportCoordinator })
        showErrorAlert(ErrorMapper.toViewError(error: error))
    }
}

extension AppCoordinator: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        // Handle drag to dismiss on the import sheet.
        childCoordinators.removeAll(where: { $0 is ImportCoordinator })
    }
}

extension AppCoordinator: IdentitiesCoordinatorDelegate {
    func noIdentitiesFound() {
        self.navigationController.setNavigationBarHidden(true, animated: false)
        showInitialIdentityCreation()
        childCoordinators.removeAll(where: { $0 is IdentitiesCoordinator ||  $0 is AccountsCoordinator  || $0 is MoreCoordinator })
    }
}
