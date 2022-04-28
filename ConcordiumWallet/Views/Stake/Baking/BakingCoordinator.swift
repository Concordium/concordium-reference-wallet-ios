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
    
    func showPoolSettings(dataHandler: StakeDataHandler) {
        let presenter = BakerPoolSettingsPresenter(delegate: self, dataHandler: dataHandler)
        
        let viewController = BakerPoolSettingsFactory.create(with: presenter)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showGenerateKey(dataHandler: StakeDataHandler) {
        let presenter = BakerPoolGenerateKeyPresenter(
            delegate: self,
            dependencyProvider: dependencyProvider,
            account: account,
            dataHandler: dataHandler
        )
        
        let viewController = BakerPoolGenerateKeyFactory.create(with: presenter)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showMetadataUrl(dataHandler: StakeDataHandler) {
        let presenter = BakerMetadataPresenter(delegate: self, dataHandler: dataHandler)
        let vc = BakerMetadataFactory.create(with: presenter)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showAmountInput(dataHandler: StakeDataHandler) {
        let presenter = BakerAmountInputPresenter(
            account: account,
            delegate: self,
            dependencyProvider: dependencyProvider,
            dataHandler: dataHandler
        )
        
        let vc = StakeAmountInputFactory.create(with: presenter)
        self.navigationController.pushViewController(vc, animated: true)
    }

    func showRequestConfirmation(cost: GTU, energy: Int, dataHandler: StakeDataHandler) {
        let presenter = BakerPoolReceiptConfirmationPresenter(
            account: account,
            dependencyProvider: dependencyProvider,
            delegate: self,
            cost: cost,
            energy: energy,
            dataHandler: dataHandler
        )
        
        let vc = StakeReceiptFactory.create(with: presenter)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showSubmissionReceipt(transfer: TransferDataType, dataHandler: StakeDataHandler) {
        let presenter = BakerPoolReceiptPresenter(
            account: account,
            dependencyProvider: dependencyProvider,
            dataHandler: dataHandler,
            transfer: transfer
        )
        
        let vc = StakeReceiptFactory.create(with: presenter)
        navigationController.pushViewController(vc, animated: true)
    }
}

extension BakingCoordinator: BakingOnboardingCoordinatorDelegate {
    func finished(mode: BakingOnboardingMode) {
        switch mode {
        case .register:
            showAmountInput(dataHandler: BakerDataHandler(account: account, action: .register))
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
    func finishedPoolSettings(dataHandler: StakeDataHandler) {
        if case .open = dataHandler.getCurrentEntry(BakerPoolSettingsData.self)?.poolSettings {
            showMetadataUrl(dataHandler: dataHandler)
        } else {
            showGenerateKey(dataHandler: dataHandler)
        }
    }
    
    func closedPoolSettings() {
        self.delegate?.finishedBakingCoordinator()
    }
}

extension BakingCoordinator: BakerPoolGenerateKeyPresenterDelegate {
    func shareExportedFile(url: URL, completion: @escaping (Bool) -> Void) {
        self.share(items: [url], from: self.navigationController, completion: completion)
    }
    
    func finishedGeneratingKeys(cost: GTU, energy: Int, dataHandler: StakeDataHandler) {
        self.showRequestConfirmation(cost: cost, energy: energy, dataHandler: dataHandler)
    }
    
    func pressedClose() {
        self.delegate?.finishedBakingCoordinator()
    }
}

extension BakingCoordinator: BakerMetadataPresenterDelegate {
    func finishedMetadata(dataHandler: StakeDataHandler) {
        showGenerateKey(dataHandler: dataHandler)
        // TODO: handle finishing of metadata (for update we show receipt; For created we show keys)
    }
    
    func closedMetadata() {
        self.delegate?.finishedBakingCoordinator()
    }
}

extension BakingCoordinator: BakerAmountInputPresenterDelegate {
    func finishedAmountInput(dataHandler: StakeDataHandler) {
        self.showPoolSettings(dataHandler: dataHandler)
    }
    
    func switchToRemoveBaker(cost: GTU, energy: Int) {
        // TODO: Delegate to remove
    }
}

extension BakingCoordinator: BakerPoolReceiptConfirmationPresenterDelegate {
    func confirmedTransaction(transfer: TransferDataType, dataHandler: StakeDataHandler) {
        self.showSubmissionReceipt(transfer: transfer, dataHandler: dataHandler)
    }
}

extension BakingCoordinator: RequestPasswordDelegate {}
