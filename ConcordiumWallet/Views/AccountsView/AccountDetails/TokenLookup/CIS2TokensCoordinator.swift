//
//  CIS2TokensCoordinator.swift
//  ConcordiumWallet
//

import SwiftUI
import UIKit

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
        navigationController.setViewControllers([UIHostingController(rootView: view)], animated: false)
    }

    private func showTokenSelectionView(with model: [CIS2TokenSelectionRepresentable]) {
        let view = CIS2TokenSelectView(
            viewModel: model,
            accountAdress: account.address,
            popView: { [weak self] () in self?.navigationController.popViewController(animated: true) },
            service: dependencyProvider.cis2Service()
        )

        navigationController.pushViewController(UIHostingController(rootView: view), animated: true)
    }
}
