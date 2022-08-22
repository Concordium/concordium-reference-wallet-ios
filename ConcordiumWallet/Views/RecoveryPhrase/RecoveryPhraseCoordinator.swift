//
//  RecoveryPhraseCoordinator.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 29/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import UIKit
import Combine

protocol RecoveryPhraseCoordinatorDelegate: AnyObject {
    func recoveryPhraseCoordinator(createdNewSeed seed: Seed)
    func recoveryPhraseCoordinatorFinishedRecovery()
}

class RecoveryPhraseCoordinator: Coordinator, RequestPasswordDelegate, ShowAlert {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    private let dependencyProvider: LoginDependencyProvider
    private weak var delegate: RecoveryPhraseCoordinatorDelegate?
    
    private var cancellables = [AnyCancellable]()
    
    init(
        dependencyProvider: LoginDependencyProvider,
        navigationController: UINavigationController,
        delegate: RecoveryPhraseCoordinatorDelegate
    ) {
        self.dependencyProvider = dependencyProvider
        self.navigationController = navigationController
        self.delegate = delegate
    }
    
    func start() {
        presentGettingStarted()
    }
    
    func presentGettingStarted() {
        let presenter = RecoveryPhraseGettingStartedPresenter(
            recoveryPhraseService: dependencyProvider.recoveryPhraseService(),
            delegate: self
        )
        
        navigationController.pushViewController(presenter.present(RecoveryPhraseGettingStartedView.self), animated: true)
    }
    
    func presentOnboarding(with recoveryPhrase: RecoveryPhrase) {
        let presenter = RecoveryPhraseOnboardingPresenter(
            recoveryPhrase: recoveryPhrase,
            delegate: self
        )
        
        replaceTopController(with: presenter.present(RecoveryPhraseOnboardingView.self))
    }
    
    func presentCopyPhrase(with recoveryPhrase: RecoveryPhrase) {
        let presenter = RecoveryPhraseCopyPhrasePresenter(
            recoveryPhrase: recoveryPhrase,
            delegate: self
        )
        
        replaceTopController(with: presenter.present(RecoveryPhraseCopyPhraseView.self))
    }
    
    func presentConfirmPhrase(with recoveryPhrase: RecoveryPhrase) {
        let presenter = RecoveryPhraseConfirmPhrasePresenter(
            recoveryPhrase: recoveryPhrase,
            recoveryPhraseService: dependencyProvider.recoveryPhraseService(),
            delegate: self
        )
        
        replaceTopController(with: presenter.present(RecoveryPhraseConfirmPhraseView.self))
    }
    
    func presentSetupComplete(with recoveryPhrase: RecoveryPhrase) {
        let presenter = RecoveryPhraseSetupCompletePresenter(
            recoveryPhrase: recoveryPhrase,
            delegate: self
        )
        
        navigationController.setViewControllers([presenter.present(RecoveryPhraseSetupCompleteView.self)], animated: true)
    }
    
    func presentRecoverIntro() {
        let presenter = RecoveryPhraseRecoverIntroPresenter(delegate: self)
        
        replaceTopController(with: presenter.present(RecoveryPhraseRecoverIntroView.self))
    }
    
    func presentRecoverExplanation() {
        let presenter = RecoveryPhraseRecoverExplanationPresenter(delegate: self)
        
        replaceTopController(with: presenter.present(RecoveryPhraseRecoverExplanationView.self))
    }
    
    func presentRecoverInput() {
        let presenter = RecoveryPhraseInputPresenter(
            recoveryService: dependencyProvider.recoveryPhraseService(),
            delegate: self
        )
        
        replaceTopController(with: presenter.present(RecoveryPhraseInputView.self))
    }
    
    func presentRecoveryCompleted(with recoveryPhrase: RecoveryPhrase) {
        let presenter = RecoveryPhraseRecoverCompletePresenter(
            recoveryPhrase: recoveryPhrase,
            delegate: self
        )
        
        navigationController.setViewControllers([presenter.present(RecoveryPhraseRecoverCompleteView.self)], animated: true)
    }
    
    func presentIdentityRecovery(with recoveryPhrase: RecoveryPhrase) {
        let presenter = IdentityRecoveryStatusPresenter(
            recoveryPhrase: recoveryPhrase,
            recoveryPhraseService: dependencyProvider.recoveryPhraseService(),
            identitiesService: dependencyProvider.seedIdentitiesService(),
            accountsService: dependencyProvider.seedAccountsService(),
            keychain: dependencyProvider.keychainWrapper(),
            delegate: self
        )
        
        replaceTopController(with: presenter.present(IdentityReccoveryStatusView.self))
    }
    
    private func replaceTopController(with controller: UIViewController) {
        let viewControllers = navigationController.viewControllers.filter { $0.isPresenting(page: RecoveryPhraseGettingStartedView.self) }
        navigationController.setViewControllers(viewControllers + [controller], animated: true)
    }
}

extension RecoveryPhraseCoordinator: RecoveryPhraseGettingStartedPresenterDelegate {    
    func setupNewWallet(with recoveryPhrase: RecoveryPhrase) {
        presentOnboarding(with: recoveryPhrase)
    }
    
    func recoverWallet() {
        presentRecoverIntro()
    }
}

extension RecoveryPhraseCoordinator: RecoveryPhraseOnboardingPresenterDelegate {
    func onboardingFinished(with recoveryPhrase: RecoveryPhrase) {
        presentCopyPhrase(with: recoveryPhrase)
    }
}

extension RecoveryPhraseCoordinator: RecoveryPhraseCopyPhrasePresenterDelegate {
    func finishedCopyingPhrase(with recoveryPhrase: RecoveryPhrase) {
        presentConfirmPhrase(with: recoveryPhrase)
    }
}

extension RecoveryPhraseCoordinator: RecoveryPhraseConfirmPhrasePresenterDelegate {
    func recoveryPhraseHasBeenConfirmed(_ recoveryPhrase: RecoveryPhrase) {
        presentSetupComplete(with: recoveryPhrase)
    }
}

extension RecoveryPhraseCoordinator: RecoveryPhraseSetupCompletePresenterDelegate {
    func recoveryPhraseSetupFinished(with recoveryPhrase: RecoveryPhrase) {
        Task {
            do {
                let pwHash = try await self.requestUserPassword(keychain: self.dependencyProvider.keychainWrapper())
                
                let seed = try self.dependencyProvider.seedMobileWallet()
                    .store(recoveryPhrase: recoveryPhrase, with: pwHash)
                    .get()
                
                self.delegate?.recoveryPhraseCoordinator(createdNewSeed: seed)
            } catch {
                if case GeneralError.userCancelled = error { return }
                self.showErrorAlert(ErrorMapper.toViewError(error: error))
            }
        }
    }
}

extension RecoveryPhraseCoordinator: RecoveryPhraseRecoverIntroPresenterDelegate {
    func recoverIntroWasFinished() {
        presentRecoverExplanation()
    }
}

extension RecoveryPhraseCoordinator: RecoveryPhraseRecoverExplanationPresenterDelegate {
    func recoverExplanationWasFinished() {
        presentRecoverInput()
    }
}

extension RecoveryPhraseCoordinator: RecoveryPhraseInputPresenterDelegate {
    func phraseInputReceived(validPhrase: RecoveryPhrase) {
        presentRecoveryCompleted(with: validPhrase)
    }
}

extension RecoveryPhraseCoordinator: RecoveryPhraseRecoverCompletePresenterDelegate {
    func completeRecovery(with recoveryPhrase: RecoveryPhrase) {
        presentIdentityRecovery(with: recoveryPhrase)
    }
}

extension RecoveryPhraseCoordinator: IdentityRecoveryStatusPresenterDelegate {
    func identityRecoveryCompleted() {
        delegate?.recoveryPhraseCoordinatorFinishedRecovery()
    }
    
    func reenterRecoveryPhrase() {
        presentRecoverInput()
    }
}
