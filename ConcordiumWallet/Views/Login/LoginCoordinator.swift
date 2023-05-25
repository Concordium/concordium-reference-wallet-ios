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

typealias TermsAndConditionsViewFactory = (TermsAndConditionsResponse) -> (TermsAndConditionsViewModel?)

class LoginCoordinator: Coordinator, ShowAlert {
    var childCoordinators = [Coordinator]()

    var navigationController: UINavigationController
    let dependencyProvider: LoginDependencyProvider
    private var cancellables: Set<AnyCancellable> = []
    private weak var parentCoordinator: LoginCoordinatorDelegate?
    private var termsAndCondtionsFactory: TermsAndConditionsViewFactory
    init(
        navigationController: UINavigationController,
        parentCoordinator: LoginCoordinatorDelegate,
        dependencyProvider: LoginDependencyProvider,
        termsAndCondtionsFactory: @escaping TermsAndConditionsViewFactory
    ) {
        self.termsAndCondtionsFactory = termsAndCondtionsFactory
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

    func show(termsAndConditions: TermsAndConditionsResponse, isPasswordCreated: Bool) {
        guard let viewModel = termsAndCondtionsFactory(termsAndConditions) else { return }
        viewModel.didAcceptTermsAndConditions = { [weak self] in
            if isPasswordCreated {
                self?.showLogin()
            } else {
                self?.showInitialScreen()
            }
        }
        let viewController = UIHostingController(rootView: TermsAndConditionsView(viewModel: viewModel))
        navigationController.pushViewController(viewController, animated: true)
    }

    func start() {
        let passwordCreated = dependencyProvider.keychainWrapper().passwordCreated()
        let acceptedVersion = dependencyProvider.storageManager().getLastAcceptedTermsAndConditionsVersion()
        dependencyProvider.appSettingsService()
            .getTermsAndConditionsVersion()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished: break
                case let .failure(serverError):
                    Logger.error(serverError)
                    self?.showErrorAlert(ErrorMapper.toViewError(error: serverError))
                }
            }, receiveValue: { [weak self] termsAndConditions in
                if termsAndConditions.version == acceptedVersion {
                    if passwordCreated {
                        self?.showLogin()
                    } else {
                        self?.showInitialScreen()
                    }
                } else {
                    self?.show(termsAndConditions: termsAndConditions, isPasswordCreated: passwordCreated)
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
