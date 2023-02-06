//
//  SeedIdentitiesCoordinator.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 04/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

protocol SeedIdentitiesCoordinatorDelegate: AnyObject {
    func seedIdentityCoordinatorWasFinished(for identity: IdentityDataType)
}

class SeedIdentitiesCoordinator: Coordinator {
    enum Action {
        case createInitialIdentity
        case createAccount
        case createIdentity
    }
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let action: Action
    private let dependencyProvider: IdentitiesFlowCoordinatorDependencyProvider
    private let identititesService: SeedIdentitiesService
    private weak var delegate: SeedIdentitiesCoordinatorDelegate?
    
    init(
        navigationController: UINavigationController,
        action: Action,
        dependencyProvider: IdentitiesFlowCoordinatorDependencyProvider,
        delegate: SeedIdentitiesCoordinatorDelegate
    ) {
        self.navigationController = navigationController
        self.action = action
        self.dependencyProvider = dependencyProvider
        self.identititesService = dependencyProvider.seedIdentitiesService()
        self.delegate = delegate
    }
    
    func start() {
        switch action {
        case .createInitialIdentity:
            if let pendingIdentity = identititesService.pendingIdentity {
                showSubmitAccount(for: pendingIdentity)
            } else {
                showOnboarding()
            }
        case .createAccount:
            showIdentitySelection()
        case .createIdentity:
            showIdentityProviders(isNewIdentityAfterSettingUpTheWallet: true)
        }
    }
    
    private func showOnboarding() {
        let presenter = SeedIdentityOnboardingPresenter(delegate: self)
        
        navigationController.setViewControllers([presenter.present(SeedIdentityOnboardingView.self)], animated: true)
    }
    
    private func showIdentityProviders(enablePop: Bool = true, isNewIdentityAfterSettingUpTheWallet: Bool = false) {
        let presenter = SelectIdentityProviderPresenter(
            identitiesService: identititesService,
            delegate: self,
            isNewIdentityAfterSettingUpTheWallet: isNewIdentityAfterSettingUpTheWallet
        )
        
        if enablePop {
            navigationController.pushViewController(
                presenter.present(SelectIdentityProviderView.self),
                animated: true)
        } else {
            navigationController.setViewControllers([presenter.present(SelectIdentityProviderView.self)], animated: true)
        }
    }
    
    private func showCreateIdentity(request: IDPIdentityRequest, isNewIdentityAfterSettingUpTheWallet: Bool = false) {
        let presenter = CreateSeedIdentityPresenter(
            request: request,
            identitiesService: identititesService,
            delegate: self,
            isNewIdentityAfterSettingUpTheWallet: isNewIdentityAfterSettingUpTheWallet
        )
        
        let viewController = presenter.present(CreateSeedIdentityView.self)
        viewController.modalPresentationStyle = .fullScreen
        navigationController.present(viewController, animated: true)
    }
    
    private func showIdentityStatus(identity: IdentityDataType, isNewIdentityAfterSettingUpTheWallet: Bool = false) {
        let presenter = SeedIdentityStatusPresenter(
            identity: identity,
            identitiesService: identititesService,
            delegate: self,
            isNewIdentityAfterSettingUpTheWallet: isNewIdentityAfterSettingUpTheWallet
        )
        
        navigationController.setViewControllers([presenter.present(SeedIdentityStatusView.self)], animated: true)
    }
    
    private func showSubmitAccount(for identity: IdentityDataType, isNewAccountAfterSettingUpTheWallet: Bool = false) {
        let presenter = SubmitSeedAccountPresenter(
            identity: identity,
            identitiesService: identititesService,
            accountsService: dependencyProvider.seedAccountsService(),
            delegate: self,
            isNewAccountAfterSettingUpTheWallet: isNewAccountAfterSettingUpTheWallet
        )
        
        navigationController.setViewControllers([presenter.present(SubmitSeedAccountView.self)], animated: true)
    }
    
    private func showIdentitySelection() {
        let presenter = SelectIdentityPresenter(
            identities: identititesService.confirmedIdentities,
            delegate: self
        )
        
        navigationController.pushViewController(presenter.present(SelectIdentityView.self), animated: true)
    }
    
    private func showSubmittedAccount(for identity: IdentityDataType) {
        let presenter = SubmittedSeedAccountPresenter(
            identity: identity,
            identitiesService: identititesService,
            accountsService: dependencyProvider.seedAccountsService(),
            delegate: self
        )
        
        navigationController.setViewControllers([presenter.present(SubmittedSeedAccountView.self)], animated: true)
    }
}

extension SeedIdentitiesCoordinator: SeedIdentityOnboardingPresenterDelegate {
    func onboardingDidFinish() {
        showIdentityProviders()
    }
}

extension SeedIdentitiesCoordinator: SelectIdentityProviderPresenterDelegate {
    func showIdentityProviderInfo(url: URL) {
        navigationController.present(
            SFSafariViewController(url: url),
            animated: true
        )
    }
    
    func createIdentityRequestCreated(_ request: IDPIdentityRequest, isNewIdentityAfterSettingUpTheWallet: Bool) {
        showCreateIdentity(request: request, isNewIdentityAfterSettingUpTheWallet: isNewIdentityAfterSettingUpTheWallet)
    }
}

extension SeedIdentitiesCoordinator: CreateSeedIdentityPresenterDelegate {
    func pendingIdentityCreated(_ identity: IdentityDataType, isNewIdentityAfterSettingUpTheWallet: Bool) {
        navigationController.dismiss(animated: true) {
            self.showIdentityStatus(identity: identity, isNewIdentityAfterSettingUpTheWallet: isNewIdentityAfterSettingUpTheWallet)
        }
    }
    
    func createIdentityView(failedToLoad error: Error) {
        navigationController.dismiss(animated: true) {
            let vc = CreationFailedFactory.create(
                with: CreationFailedPresenter(
                    serverError: error,
                    delegate: self,
                    mode: .identity
                )
            )
            self.showModally(vc, from: self.navigationController)
        }
    }
    
    func cancelCreateIdentity() {
        navigationController.dismiss(animated: true)
    }
}

extension SeedIdentitiesCoordinator: CreationFailedPresenterDelegate {
    func finish() {
        
    }
}

extension SeedIdentitiesCoordinator: SeedIdentityStatusPresenterDelegate {
    func seedIdentityStatusDidFinish(with identity: IdentityDataType) {
        showSubmitAccount(for: identity)
    }
    
    func seedNewIdentityStatusDidFinish(with identity: IdentityDataType) {
        delegate?.seedIdentityCoordinatorWasFinished(for: identity)
    }
    
    func makeNewIdentityRequestAfterSettingUpWallet() {
        showIdentityProviders(enablePop: false, isNewIdentityAfterSettingUpTheWallet: true)
    }
    
    func makeNewAccount(with identity: IdentityDataType) {
        showSubmitAccount(for: identity, isNewAccountAfterSettingUpTheWallet: true)
    }
}

extension SeedIdentitiesCoordinator: SubmitSeedAccountPresenterDelegate {
    func accountHasBeenSubmitted(_ account: AccountDataType, isNewAccountAfterSettingUpTheWallet: Bool, forIdentity identity: IdentityDataType) {
        if isNewAccountAfterSettingUpTheWallet {
            showSubmittedAccount(for: identity)
        } else {
            delegate?.seedIdentityCoordinatorWasFinished(for: identity)
        }
    }
    
    func makeNewIdentityRequest() {
        showIdentityProviders(enablePop: false)
    }
}

extension SeedIdentitiesCoordinator: SelectIdentityPresenterDelegate {
    func selectIdentityPresenter(didSelectIdentity identity: IdentityDataType) {
        showSubmitAccount(for: identity, isNewAccountAfterSettingUpTheWallet: true)
    }
}

extension SeedIdentitiesCoordinator: SubmittedSeedAccountPresenterDelegate {
    func accountHasBeenFinished(for identity: IdentityDataType) {
        delegate?.seedIdentityCoordinatorWasFinished(for: identity)
    }
}
