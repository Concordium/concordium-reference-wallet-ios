//
//  CIS2TokensCoordinator.swift
//  ConcordiumWallet
//

import UIKit
import SwiftUI

class CIS2TokensCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    private var dependencyProvider: CIS2TokensCoordinatorDependencyProvider

    init(
        navigationController: UINavigationController,
        dependencyProvider: CIS2TokensCoordinatorDependencyProvider
    ) {
        self.navigationController = navigationController
        self.dependencyProvider = dependencyProvider
    }

    func start() {
        var view = TokenLookupView(service: dependencyProvider.cis2Service())
        view.didTapSearch = { [weak self] tokens in
            self?.navigationController.pushViewController(UIViewController(), animated: true)
        }
        self.navigationController.setViewControllers([UIHostingController(rootView: view)], animated: false)
    }
}
