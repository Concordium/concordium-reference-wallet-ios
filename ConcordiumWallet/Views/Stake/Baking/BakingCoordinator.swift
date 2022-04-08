//
//  BakingCoordinator.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 07/04/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import UIKit

protocol BakingCoordinatorDelegate: Coordinator {
    func finishedBakingCoordinator()
}

class BakingCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    private weak var delegate: BakingCoordinatorDelegate?
    private let account: AccountDataType
    private let dependencyProvider: StakeCoordinatorDependencyProvider
    
    init(
        navigationController: UINavigationController,
        dependencyProvider: StakeCoordinatorDependencyProvider,
        account: AccountDataType,
        parentCoordinator: BakingCoordinatorDelegate
    ) {
        self.navigationController = navigationController
        navigationController.modalPresentationStyle = .fullScreen
        self.account = account
        self.delegate = parentCoordinator
        self.dependencyProvider = dependencyProvider
    }
    
    func start() {
        // TODO: Implement actual navigation flow
        
        showPoolSettings(transferType: .registerBaker)
    }
    
    func showPoolSettings(transferType: TransferType) {
        let presenter = BakerPoolSettingsPresenter(delegate: self, dataHandler: StakeDataHandler(transferType: transferType))
        
        let viewController = BakerPoolSettingsFactory.create(with: presenter)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showGenerateKey() {
        let presenter = BakerPoolGenerateKeyPresenter(delegate: self, dependencyProvider: dependencyProvider)
        
        let viewController = BakerPoolGenerateKeyFactory.create(with: presenter)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension BakingCoordinator: BakerPoolSettingsPresenterDelegate {
    func finishedPoolSettings() {
        showGenerateKey()
    }
    
    func closedPoolSettings() {
        self.delegate?.finishedBakingCoordinator()
    }
}

extension BakingCoordinator: BakerPoolGenerateKeyPresenterDelegate {
    func pressedClose() {
        self.delegate?.finishedBakingCoordinator()
    }
    
    func pressedExportKeys(keys: GeneratedBakerKeys) {
        
    }
}
