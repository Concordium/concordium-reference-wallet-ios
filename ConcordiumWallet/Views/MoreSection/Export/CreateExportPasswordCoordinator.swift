//
// Created by Concordium on 26/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import UIKit
import Combine

class CreateExportPasswordCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private var dependencyProvider: MoreFlowCoordinatorDependencyProvider

    let passwordPublisher = PassthroughSubject<String, Error>()

    init(navigationController: UINavigationController, dependencyProvider: MoreFlowCoordinatorDependencyProvider) {
        self.navigationController = navigationController
        self.dependencyProvider = dependencyProvider
    }

    func start() {
        let vc = EnterPasswordFactory.create(with: CreateExportPasswordPresenter(delegate: self))
        navigationController.viewControllers = [vc]
    }
}

extension CreateExportPasswordCoordinator: CreateExportPasswordPresenterDelegate {
    func passwordSelectionDone(password: String) {
        passwordPublisher.send(password)
        passwordPublisher.send(completion: .finished)
    }

    func passwordSelectionCancelled() {
        passwordPublisher.send(completion: .failure(GeneralError.userCancelled))
    }
}
