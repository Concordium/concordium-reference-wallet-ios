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

class SeedIdentitiesCoordinator: Coordinator {
    enum Action {
        case createInitialIdentity
    }
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let action: Action
    private let dependencyProvider: IdentitiesFlowCoordinatorDependencyProvider
    private let identititesService: IdentitiesService
    
    init(
        navigationController: UINavigationController,
        action: Action,
        dependencyProvider: IdentitiesFlowCoordinatorDependencyProvider
    ) {
        self.navigationController = navigationController
        self.action = action
        self.dependencyProvider = dependencyProvider
        self.identititesService = dependencyProvider.identitiesService()
    }
    
    func start() {
        switch action {
        case .createInitialIdentity:
            if let pendingIdentity = identititesService.pendingIdentity {
                showIdentityStatus(identity: pendingIdentity)
            } else {
                showOnboarding()
            }
        }
    }
    
    private func showOnboarding() {
        let presenter = SeedIdentityOnboardingPresenter(delegate: self)
        
        navigationController.setViewControllers([presenter.present(SeedIdentityOnboardingView.self)], animated: true)
    }
    
    private func showIdentityProviders() {
        let presenter = SelectIdentityProviderPresenter(
            index: identititesService.nextIdentityIndex,
            identitiesService: identititesService,
            wallet: dependencyProvider.seedMobileWallet(),
            delegate: self
        )
        
        navigationController.pushViewController(
            presenter.present(SelectIdentityProviderView.self),
            animated: true
        )
    }
    
    private func showCreateIdentity(request: SeedIdentityRequest) {
        let presenter = CreateSeedIdentityPresenter(
            request: request,
            identitiesService: identititesService,
            delegate: self
        )
        
        let viewController = presenter.present(CreateSeedIdentityView.self)
        viewController.modalPresentationStyle = .fullScreen
        navigationController.present(viewController, animated: true)
    }
    
    private func showIdentityStatus(identity: SeedIdentityDataType) {
        let presenter = SeedIdentityStatusPresenter(delegate: self)
        
        navigationController.setViewControllers([presenter.present(SeedIdentityStatusView.self)], animated: true)
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
    
    func createIdentityRequestCreated(_ request: SeedIdentityRequest) {
        showCreateIdentity(request: request)
    }
}

extension SeedIdentitiesCoordinator: CreateSeedIdentityPresenterDelegate {
    func pendingIdentityCreated(_ identity: SeedIdentityDataType) {
        navigationController.dismiss(animated: true) {
            self.showIdentityStatus(identity: identity)
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
    
}

struct SeedIdentityRequest {
    let id: String
    let index: Int
    let identityProvider: IdentityProviderDataType
    let webRequest: ResourceRequest
}
