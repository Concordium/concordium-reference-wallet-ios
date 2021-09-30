//
//  UpdatePasswordCoordinator.swift
//  ConcordiumWallet
//
//  Created by Concordium on 05/03/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation
import UIKit
import Combine

protocol UpdatePasswordCoordinatorDelegate: AnyObject {
    func passcodeChanged()
}

class UpdatePasswordCoordinator: Coordinator, ShowAlert {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var parentCoordinator: UpdatePasswordCoordinatorDelegate
    private var dependencyProvider: LoginDependencyProvider
    private var walletAndStorage: WalletAndStorageDependencyProvider
    private weak var requestPasswordDelegate: RequestPasswordDelegate?
    private var previousPwHashed: String?
    private var cancellables: [AnyCancellable] = []
    
    init(navigationController: UINavigationController,
         parentCoordinator: UpdatePasswordCoordinatorDelegate,
         requestPasswordDelegate: RequestPasswordDelegate,
         dependencyProvider: LoginDependencyProvider,
         walletAndStorage: WalletAndStorageDependencyProvider) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.requestPasswordDelegate = requestPasswordDelegate
        self.dependencyProvider = dependencyProvider
        self.walletAndStorage = walletAndStorage
    }
    
    func start() {
        showUpdateInfo()
    }
    
    func showUpdateInfo() {
        let vc = UpdatePasswordFactory.create(with: UpdatePasswordPresenter(delegate: self))
        navigationController.pushViewController(vc, animated: true)
    }
    
    func requestPassword() {
        // Ask for current passcode before proceeding to passcode change.
        self.requestPasswordDelegate?
            .requestUserPassword(keychain: dependencyProvider.keychainWrapper())
            .sink(receiveError: { error in
                if case GeneralError.userCancelled = error { return }
            }, receiveValue: { [weak self] pwHash in
                self?.previousPwHashed = pwHash
                self?.showChangePassword()
            }).store(in: &cancellables)
        
    }
    
    func showChangePassword() {
        let presenter = ChangePasswordPresenter(delegate: self,
                                                dependencyProvider: dependencyProvider,
                                                walletAndStorage: walletAndStorage,
                                                oldPasscodeHash: previousPwHashed)
        let vc = EnterPasswordFactory.create(with: presenter)
        let nc = TransparentNavigationController()
        nc.modalPresentationStyle = .fullScreen
        nc.viewControllers = [vc]
        self.navigationController.present(nc, animated: true)
    }
    
    func showBiometricsEnabling(pwHash: String) {
        let presenter = BiometricsEnablingPresenter(delegate: self, pwHash: pwHash, dependencyProvider: dependencyProvider)
        if presenter.biometricsEnabled() {
            let vc = BiometricsEnablingFactory.create(with: presenter)
            let nc = TransparentNavigationController()
            nc.modalPresentationStyle = .fullScreen
            nc.viewControllers = [vc]
            self.navigationController.present(nc, animated: true)
        } else {
            biometricsEnablingDone()
        }
    }
}

extension UpdatePasswordCoordinator: UpdatePasswordPresenterDelegate {
    
    func showChangePasscode() {
        let accountsNotFinalized = self.walletAndStorage.storageManager().getAccounts().contains { $0.transactionStatus != .finalized }
        let identitiesNotConfirmed = self.walletAndStorage.storageManager().getIdentities().contains { $0.state != .confirmed}

        if accountsNotFinalized || identitiesNotConfirmed {
            self.showErrorAlert(.simpleError(localizedReason: "more.update.error.nonFinalizedItems".localized))
        } else {
            requestPassword()
        }
    }
    
    func setPreviousPwHashed(pwHash: String) {
        self.previousPwHashed = pwHash
    }
}

extension UpdatePasswordCoordinator: ChangePasswordPresenterDelegate {
    func passwordSelectionDone(pwHash: String) {
        navigationController.dismiss(animated: true)
        self.showBiometricsEnabling(pwHash: pwHash)
    }
    
    func passwordChangeFailed() {
        navigationController.dismiss(animated: true)    
    }
}

extension UpdatePasswordCoordinator: BiometricsEnablingPresenterDelegate {
    func biometricsEnablingDone() {

        navigationController.dismiss(animated: true)

        self.parentCoordinator.passcodeChanged()
    }
}
