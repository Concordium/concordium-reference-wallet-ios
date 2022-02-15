//
//  InitialAccountsCoordinator.swift
//  ConcordiumWallet
//
//  Concordium on 11/11/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

protocol InitialAccountsCoordinatorDelegate: AnyObject {
    func finishedCreatingInitialIdentity()
}

class InitialAccountsCoordinator: Coordinator, ShowAlert {
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
        AppSettings.lastKnownAppVersion = AppSettings.appVersion // Surpress the welcome back backup warning
    }

    func showGettingStarted() {
        let gettingStartedPresenter = GettingStartedPresenter(delegate: self)
        let vc = GettingStartedFactory.create(with: gettingStartedPresenter)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showCreateNewAccount(withDefaultValuesFrom account: AccountDataType? = nil) {
        let createIdentityCoordinator = CreateIdentityCoordinator(navigationController: navigationController,
                                                                  dependencyProvider: identitiesProvider,
                                                                  parentCoordinator: self)
        childCoordinators.append(createIdentityCoordinator)
        createIdentityCoordinator.startInitialAccount(withDefaultValuesFrom: account)
    }

    func showImportInfo() {
        let initialAccountPresenter = InitialAccountInfoPresenter(delegate: self, type: .importAccount)
        let vc = InitialAccountInfoFactory.create(with: initialAccountPresenter)
        vc.title = initialAccountPresenter.type.getViewModel().title
        navigationController.pushViewController(vc, animated: true)
    }

    func showIntoOnboardingFlow() {
        let onboardingCarouselViewModel = OnboardingCarouselViewModel(
            title: "onboardingcarousel.introflow.title".localized,
            pages: [
                OnboardingPage(
                    title: "onboardingcarousel.introflow.page1.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "intro_flow_onboarding_en_1")
                ),
                OnboardingPage(
                    title: "onboardingcarousel.introflow.page2.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "intro_flow_onboarding_en_2")
                ),
                OnboardingPage(
                    title: "onboardingcarousel.introflow.page3.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "intro_flow_onboarding_en_3")
                ),
                OnboardingPage(
                    title: "onboardingcarousel.introflow.page4.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "intro_flow_onboarding_en_4")
                ),
                OnboardingPage(
                    title: "onboardingcarousel.introflow.page5.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "intro_flow_onboarding_en_5")
                )
            ]
        )

        let onboardingCarouselPresenter = OnboardingCarouselPresenter(
            delegate: self,
            viewModel: onboardingCarouselViewModel
        )

        let onboardingCarouselViewController = OnboardingCarouselFactory.create(with: onboardingCarouselPresenter)
        onboardingCarouselViewController.hidesBottomBarWhenPushed = true

        navigationController.pushViewController(onboardingCarouselViewController, animated: true)
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
        showIntoOnboardingFlow()
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
            break // no action for new account - we shouldn't reach it in this flow
        case .welcomeScreen:
            break // no action for new account - we shouldn't reach it in this flow
        }
    }
}

extension InitialAccountsCoordinator: OnboardingCarouselPresenterDelegate {
    func onboardingCarouselClosed() {
        navigationController.popToRootViewController(animated: true)
    }

    func onboardingCarouselSkiped() {
        showCreateNewAccount()
    }

    func onboardingCarouselFinished() {
        showCreateNewAccount()
    }
}
