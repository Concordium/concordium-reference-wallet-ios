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
        view.didTapSearch = { [weak self] metadata in
            self?.showTokenSelectionView(with: metadata)
        }
        self.navigationController.setViewControllers([UIHostingController(rootView: view)], animated: false)
    }
    
    private func showTokenSelectionView(with metadata: CIS2TokensMetadata) {
        var view = TokenSelectionView(metadata: metadata)
        view.popView = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(UIHostingController(rootView: view), animated: true)
    }
}
