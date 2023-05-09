//
//  LoginCoordinator.swift
//  ConcordiumWallet
//
//  Created by Concordium on 18/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Combine
import SwiftUI
import UIKit

// sourcery: AutoMockable
protocol LoginCoordinatorDelegate: AppSettingsDelegate {
    func loginDone()
    func passwordSelectionDone()
}

class LoginCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()

    var navigationController: UINavigationController
    let dependencyProvider: LoginDependencyProvider
    private var cancellables: Set<AnyCancellable> = []
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

    func show(termsAndConditions: TermsAndConditionsResponse) {
        let viewModel = TermsAndConditionsViewModel(
            storageManager: dependencyProvider.storageManager(),
            termsAndConditions: termsAndConditions
        )
        viewModel.didAcceptTermsAndConditions = { [weak self] in
            self?.showInitialScreen()
        }
        let vc = UIHostingController(rootView: TermsAndConditionsView(viewModel: viewModel))
        navigationController.pushViewController(vc, animated: true)
    }

    func showError(_ error: NetworkError) {
        let alert = UIAlertController(title: "errorAlert.title".localized, message: "errorAlert.unexpected.error".localized, preferredStyle: .alert)
        let action = UIAlertAction(title: "errorAlert.retry".localized, style: .default, handler: { _ in
            self.start()
        })
        alert.addAction(action)
        navigationController.present(alert, animated: true, completion: nil)
    }

    func start() {
        let passwordCreated = dependencyProvider.keychainWrapper().passwordCreated()
        let version = dependencyProvider.storageManager().getLastAcceptedTermsAndConditionsVersion()
        dependencyProvider.appSettingsService()
            .getTermsAndConditionsVersion()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished: break
                case let .failure(error):
                    self?.showError(error as? NetworkError ?? .communicationError(error: error))
                }
            }, receiveValue: { [weak self] termsAndConditions in
                if passwordCreated && termsAndConditions.version == version {
                    self?.showLogin()
                } else {
                    self?.show(termsAndConditions: termsAndConditions)
                }
            })
            .store(in: &cancellables)
    }
}

extension LoginCoordinator: CreatePasswordPresenterDelegate {
    func passwordSelectionDone(pwHash: String) {
        showBiometricsEnabling(pwHash: pwHash)
    }
}

extension LoginCoordinator: LoginViewDelegate {
    func loginDone() {
        parentCoordinator?.loginDone()
    }
}

extension LoginCoordinator: BiometricsEnablingPresenterDelegate {
    func biometricsEnablingDone() {
        parentCoordinator?.passwordSelectionDone()
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
