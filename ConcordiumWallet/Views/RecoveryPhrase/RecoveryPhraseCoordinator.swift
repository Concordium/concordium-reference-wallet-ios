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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        presentGettingStarted()
    }
    
    func presentGettingStarted() {
        let presenter = RecoveryPhraseGettingStartedPresenter(delegate: self)
        
        navigationController.pushViewController(presenter.present(RecoveryPhraseGettingStartedView.self), animated: true)
    }
}

extension RecoveryPhraseCoordinator: RecoveryPhraseGettingStartedPresenterDelegate {
    func setupNewWallet() {
        
    }
    
    func recoverWallet() {
        
    }
}
