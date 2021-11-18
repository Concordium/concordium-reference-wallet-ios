//
//  LoginCoordinator.swift
//  ConcordiumWallet
//
//  Created by Concordium on 18/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

protocol LoginCoordinatorDelegate: AnyObject {
    func loginDone()
    func passwordSelectionDone()
}

class LoginCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()

    var navigationController: UINavigationController
    let dependencyProvider: LoginDependencyProvider

    private weak var parentCoordinator: LoginCoordinatorDelegate?

    init(navigationController: UINavigationController, parentCoordinator: LoginCoordinatorDelegate, dependencyProvider: LoginDependencyProvider) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.dependencyProvider = dependencyProvider
    }

    func showPasscodeSelection() {
        let vc = EnterPasswordFactory.create(with: CreatePasswordPresenter(delegate: self, dependencyProvider: dependencyProvider))
        navigationController.pushViewController(vc, animated: true)
    }

    func showLogin() {
        let vc = EnterPasswordFactory.create(with: LoginPresenter(delegate: self, dependencyProvider: dependencyProvider))
        navigationController.setupTransparentNavigationControllerStyle()
        navigationController.pushViewController(vc, animated: false)
    }

    func showBiometricsEnabling(pwHash: String) {
        let presenter = BiometricsEnablingPresenter(delegate: self, pwHash: pwHash, dependencyProvider: dependencyProvider)
        if presenter.biometricsEnabled() {
            let vc = BiometricsEnablingFactory.create(with: presenter)
            navigationController.pushViewController(vc, animated: true)
        } else {
            biometricsEnablingDone()
        }
    }
    
    func showInitialScreen() {
        let initialAccountPresenter = InitialAccountInfoPresenter(delegate: self, type: .welcomeScreen)
        let vc = InitialAccountInfoFactory.create(with: initialAccountPresenter)
        navigationController.pushViewController(vc, animated: true)
    }

    func showTermsAndConditionsScreen() {
        let TermsAndConditionsPresenter = TermsAndConditionsPresenter(delegate: self)
        let vc = TermsAndConditionsFactory.create(with: TermsAndConditionsPresenter)
        navigationController.pushViewController(vc, animated: true)
    }

    func start() {
        let passwordCreated = dependencyProvider.keychainWrapper().passwordCreated()
        if passwordCreated {
            showLogin()
        } else {    
            showTermsAndConditionsScreen()
        }
    }
}

extension LoginCoordinator: CreatePasswordPresenterDelegate {
    func passwordSelectionDone(pwHash: String) {
        self.showBiometricsEnabling(pwHash: pwHash)
    }
}

extension LoginCoordinator: LoginViewDelegate {
    func loginDone() {
        self.parentCoordinator?.loginDone()
    }
}

extension LoginCoordinator: BiometricsEnablingPresenterDelegate {
    func biometricsEnablingDone() {
        self.parentCoordinator?.passwordSelectionDone()
    }
}

extension LoginCoordinator: InitialAccountInfoPresenterDelegate {
    func userTappedClose() {
        // Nothing to do here.
    }
    
    func userTappedOK(withType type: InitialAccountInfoType) {
        switch type {
        case .firstAccount:
            break // No action for new account - we shouldn't reach it in this flow.
        case .importAccount:
            break // No action for new account - we shouldn't reach it in this flow.
        case .newAccount:
            break // No action for new account - we shouldn't reach it in this flow.
        case .welcomeScreen:
            showPasscodeSelection()
        }
    }
}

extension LoginCoordinator: TermsAndConditionsPresenterDelegate {
    func userTappedAcceptTerms() {
        showInitialScreen()
    }
}
