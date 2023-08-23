//
//  CIS2TokensCoordinator.swift
//  ConcordiumWallet
//

import UIKit
import SwiftUI

class CIS2TokensCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    private var account: AccountDataType
    private var dependencyProvider: CIS2TokensCoordinatorDependencyProvider

    init(
        navigationController: UINavigationController,
        dependencyProvider: CIS2TokensCoordinatorDependencyProvider,
        account: AccountDataType
    ) {
        self.navigationController = navigationController
        self.dependencyProvider = dependencyProvider
        self.account = account
    }

    func start() {
        var view = TokenLookupView(service: dependencyProvider.cis2Service(), account: account)
        view.displayContractTokens = { [weak self] data in
            self?.showTokenSelectionView(with: data)
        }
        self.navigationController.setViewControllers([UIHostingController(rootView: view)], animated: false)
    }
    
    private func showTokenSelectionView(with model: [CIS2TokenSelectionRepresentable]) {
        var view = CIS2TokenSelectView(viewModel: model)
        view.popView = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(UIHostingController(rootView: view), animated: true)
    }
}
