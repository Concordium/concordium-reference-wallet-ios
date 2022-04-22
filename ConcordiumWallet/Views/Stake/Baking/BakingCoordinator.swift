//
//  BakingCoordinator.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 07/04/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import UIKit
import Combine

protocol BakingCoordinatorDelegate: Coordinator {
    func finishedBakingCoordinator()
}

class BakingCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    private weak var delegate: BakingCoordinatorDelegate?
    private let account: AccountDataType
    private let dependencyProvider: StakeCoordinatorDependencyProvider
    
    private lazy var stakeService: StakeServiceProtocol = {
        self.dependencyProvider.stakeService()
    }()
    
    private let bakingDataHandler: StakeDataHandler
    private var cancellables = Set<AnyCancellable>()
    
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
        self.bakingDataHandler = BakerDataHandler(account: account, action: .register)
    }
    
    func start() {
        // TODO: Implement actual navigation flow
        
        showCarousel(mode: .register)
    }
    
    func showCarousel(mode: BakingOnboardingMode) {
        let onboardingCoordinator = BakingOnboardingCoordinator(
            navigationController: navigationController,
            parentCoordinator: self,
            mode: mode
        )
        childCoordinators.append(onboardingCoordinator)
        onboardingCoordinator.start()
    }
    
    func showPoolSettings() {
        let presenter = BakerPoolSettingsPresenter(delegate: self, dataHandler: bakingDataHandler)
        
        let viewController = BakerPoolSettingsFactory.create(with: presenter)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showGenerateKey() {
        let presenter = BakerPoolGenerateKeyPresenter(
            delegate: self,
            dependencyProvider: dependencyProvider,
            account: account,
            dataHandler: bakingDataHandler
        )
        
        let viewController = BakerPoolGenerateKeyFactory.create(with: presenter)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showMetadataUrl() {
        let presenter = BakerMetadataPresenter(delegate: self, dataHandler: bakingDataHandler)
        let vc = BakerMetadataFactory.create(with: presenter)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showAmountInput() {
        let presenter = BakerAmountInputPresenter(
            account: self.account,
            delegate: self,
            dependencyProvider: self.dependencyProvider,
            dataHandler: self.bakingDataHandler
        )
        
        let vc = StakeAmountInputFactory.create(with: presenter)
        self.navigationController.pushViewController(vc, animated: true)
    }
}

extension BakingCoordinator: BakingOnboardingCoordinatorDelegate {
    func finished(mode: BakingOnboardingMode) {
        switch mode {
        case .register:
            showAmountInput()
        default:
            break
        }
    }
    
    func closed() {
        self.childCoordinators.removeAll(where: { $0 is BakingOnboardingCoordinator })
        self.delegate?.finishedBakingCoordinator()
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
    func shareExportedFile(url: URL, completion: @escaping () -> Void) {
        self.share(items: [url], from: self.navigationController) { completed in
            completion()
            if completed {
                self.delegate?.finishedBakingCoordinator()
            }
        }
    }
    
    func pressedClose() {
        self.delegate?.finishedBakingCoordinator()
    }
}

extension BakingCoordinator: BakerMetadataPresenterDelegate {
    func finishedMetadata() {
        // TODO: handle finishing of metadata (for update we show receipt; For created we show keys)
    }
    
    func closedMetadata() {
        self.delegate?.finishedBakingCoordinator()
    }
}

extension BakingCoordinator: BakerAmountInputPresenterDelegate {
    func finishedAmountInput() {
        self.showPoolSettings()
    }
    
    func switchToRemoveBaker(cost: GTU, energy: Int) {
        // TODO: Delegate to remove
    }
}
