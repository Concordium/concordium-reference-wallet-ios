//
// Created by Concordium on 11/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation

@MainActor
protocol AddRecipientCoordinatorHelper: Coordinator {
    func getAddRecipientViewController(dependencyProvider: WalletAndStorageDependencyProvider) -> AddRecipientViewController
}

extension AddRecipientCoordinatorHelper where Self: AddRecipientPresenterDelegate {
    func getAddRecipientViewController(dependencyProvider: WalletAndStorageDependencyProvider) -> AddRecipientViewController {
        let addRecInHierarchy = self.navigationController.viewControllers.last { $0 is AddRecipientViewController }
                as? AddRecipientViewController
        let addRecipientViewController = addRecInHierarchy ?? insertAddRecipientViewController(dependencyProvider: dependencyProvider)
        return addRecipientViewController
    }

    private func insertAddRecipientViewController(dependencyProvider: WalletAndStorageDependencyProvider) -> AddRecipientViewController {
        let vc = AddRecipientFactory.create(with: AddRecipientPresenter(delegate: self, dependencyProvider: dependencyProvider, mode: .add))
        var vcs = navigationController.viewControllers
        vcs.insert(vc, at: vcs.count-1)
        navigationController.setViewControllers(vcs, animated: false)
        return vc
    }
}
