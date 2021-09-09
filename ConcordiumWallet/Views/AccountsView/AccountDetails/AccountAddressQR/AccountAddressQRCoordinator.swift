//
// Created by Concordium on 15/04/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import UIKit
protocol AccountAddressQRCoordinatorDelegate: AnyObject {
    func accountAddressQRCoordinatorFinished()
}

class AccountAddressQRCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    weak var parentCoordinator: AccountAddressQRCoordinatorDelegate?

    var navigationController: UINavigationController
    private var account: AccountDataType

    init(navigationController: UINavigationController,
         delegate: AccountAddressQRCoordinatorDelegate,
         account: AccountDataType) {
        self.account = account
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .fullScreen
        self.parentCoordinator = delegate
    }

    func start() {
        let vc = AccountAddressQRFactory.create(with: AccountAddressQRPresenter(delegate: self, account: account))
        navigationController.viewControllers = [vc]
    }
}

extension AccountAddressQRCoordinator: AccountAddressQRPresenterDelegate {
    func accountAddressQRPresenterDidFinish(_ presenter: AccountAddressQRPresenter) {
        parentCoordinator?.accountAddressQRCoordinatorFinished()
    }

    func shareButtonTapped() {
        let vc = UIActivityViewController(activityItems: [account.address], applicationActivities: [])
        navigationController.present(vc, animated: true)
    }

    func copyButtonTapped() {
        CopyPasterHelper.copy(string: account.address)
    }
}
