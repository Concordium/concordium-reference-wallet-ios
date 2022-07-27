//
//  RecoveryPhraseCoordinator.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 29/06/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import UIKit

class RecoveryPhraseCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    private let dependencyProvider: LoginDependencyProvider
    
    init(
        dependencyProvider: LoginDependencyProvider,
        navigationController: UINavigationController
    ) {
        self.dependencyProvider = dependencyProvider
        self.navigationController = navigationController
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
        
        navigationController.pushViewController(presenter.present(RecoveryPhraseOnboardingView.self), animated: true)
    }
    
    func presentCopyPhrase(with recoveryPhrase: RecoveryPhrase) {
        let presenter = RecoveryPhraseCopyPhrasePresenter(
            recoveryPhrase: recoveryPhrase,
            delegate: self
        )
        
        navigationController.pushViewController(presenter.present(RecoveryPhraseCopyPhraseView.self), animated: true)
    }
    
    func presentConfirmPhrase(with recoveryPhrase: RecoveryPhrase) {
        let presenter = RecoveryPhraseConfirmPhrasePresenter(
            recoveryPhrase: recoveryPhrase,
            recoveryPhraseService: dependencyProvider.recoveryPhraseService(),
            delegate: self
        )
        
        navigationController.pushViewController(presenter.present(RecoveryPhraseConfirmPhraseView.self), animated: true)
    }
}

extension RecoveryPhraseCoordinator: RecoveryPhraseGettingStartedPresenterDelegate {
    func setupNewWallet(with recoveryPhrase: RecoveryPhrase) {
        presentOnboarding(with: recoveryPhrase)
    }
    
    func recoverWallet() {
        
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
    
}
