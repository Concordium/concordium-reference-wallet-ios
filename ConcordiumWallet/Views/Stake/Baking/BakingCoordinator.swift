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
import SwiftUI

protocol BakingCoordinatorDelegate: Coordinator {
    func finishedBakingCoordinator()
}

class BakingCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    private weak var delegate: BakingCoordinatorDelegate?
    private let account: AccountDataType
    private let dependencyProvider: StakeCoordinatorDependencyProvider
    private lazy var storageManager = dependencyProvider.storageManager()
    
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
        if storageManager.hasPendingBakerRegistration(for: account.address) {
            showStatus(status: .pendingTransfer)
        } else if let currentSettings = account.baker {
            showStatus(status: .registered(currentSettings: currentSettings))
        } else {
            showCarousel(
                dataHandler: BakerDataHandler(
                    account: account,
                    action: .register
                )
            )
        }
    }
    
    func showStatus(status: BakerPoolStatus) {
        let statusPresenter = BakerPoolStatusPresenter(
            account: account,
            status: status,
            dependencyProvider: dependencyProvider,
            delegate: self
        )
        let vc = StakeStatusFactory.create(with: statusPresenter)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showMenu(currentSettings: BakerDataType, poolInfo: PoolInfo) {
        let menuPresenter = BakerPoolMenuPresenter(
            currentSettings: currentSettings,
            poolInfo: poolInfo,
            delegate: self,
            dependencyProvider: dependencyProvider
        )
        let vc = BurgerMenuFactory.create(with: menuPresenter)
        vc.modalPresentationStyle = .overFullScreen
        navigationController.present(vc, animated: false)
    }
    
    func showCarousel(dataHandler: StakeDataHandler) {
        let onboardingCoordinator = BakingOnboardingCoordinator(
            navigationController: navigationController,
            parentCoordinator: self,
            dataHandler: dataHandler
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

    func showComissionSettings(dataHandler: StakeDataHandler) {
        let viewModel = BakerCommissionSettingsViewModel(
            service: dependencyProvider.stakeService(),
            handler: dataHandler,
            didTapContinue: { [weak self] in
            self?.showMetadataUrl(dataHandler: dataHandler)
            }) { [weak self] in
                self?.navigationController.popViewController(animated: true)
            }

        let view = BakerCommissionSettingsView(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
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

    func showRequestConfirmation(dataHandler: StakeDataHandler) {
        let presenter = BakerPoolReceiptConfirmationPresenter(
            account: account,
            dependencyProvider: dependencyProvider,
            delegate: self,
            dataHandler: dataHandler
        )
        
        let vc = StakeReceiptFactory.create(with: presenter)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showSubmissionReceipt(transfer: TransferDataType, dataHandler: StakeDataHandler) {
        let presenter = BakerPoolReceiptPresenter(
            account: account,
            delegate: self,
            dependencyProvider: dependencyProvider,
            dataHandler: dataHandler,
            transfer: transfer
        )
        
        let vc = StakeReceiptFactory.create(with: presenter)
        navigationController.pushViewController(vc, animated: true)
    }
}

extension BakingCoordinator: BakerPoolStatusPresenterDelegate {
    func pressedOpenMenu(currentSettings: BakerDataType, poolInfo: PoolInfo) {
        showMenu(currentSettings: currentSettings, poolInfo: poolInfo)
    }
}

extension BakingCoordinator: BakerPoolMenuPresenterDelegate {
    func pressed(
        action: BakerPoolMenuAction,
        currentSettings: BakerDataType,
        poolInfo: PoolInfo
    ) {
        switch action {
        case .updateBakerStake:
            showCarousel(
                dataHandler: BakerDataHandler(
                    account: account,
                    action: .updateBakerStake(currentSettings, poolInfo)
                )
            )
        case .updatePoolSettings:
            showCarousel(
                dataHandler: BakerDataHandler(
                    account: account,
                    action: .updatePoolSettings(currentSettings, poolInfo)
                )
            )
        case .updateBakerKeys:
            showCarousel(
                dataHandler: BakerDataHandler(
                    account: account,
                    action: .updateBakerKeys(currentSettings, poolInfo)
                )
            )
        case .stopBaking:
            showCarousel(
                dataHandler: BakerDataHandler(
                    account: account,
                    action: .stopBaking
                )
            )
        }
        navigationController.dismiss(animated: false)
    }
    
    func pressedDismiss() {
        navigationController.dismiss(animated: false)
    }

}

extension BakingCoordinator: BakingOnboardingCoordinatorDelegate {
    func finished(dataHandler: StakeDataHandler) {
        switch dataHandler.transferType {
        case .registerBaker:
            showAmountInput(dataHandler: dataHandler)
        case .updateBakerStake:
            showAmountInput(dataHandler: dataHandler)
        case .updateBakerPool:
            showPoolSettings(dataHandler: dataHandler)
        case .updateBakerKeys:
            showGenerateKey(dataHandler: dataHandler)
        case .removeBaker:
            showRequestConfirmation(dataHandler: dataHandler)
        default:
            self.delegate?.finishedBakingCoordinator()
        }
    }
    
    func closed() {
        self.childCoordinators.removeAll(where: { $0 is BakingOnboardingCoordinator })
        self.delegate?.finishedBakingCoordinator()
    }
}

extension BakingCoordinator: BakerPoolSettingsPresenterDelegate {
    func finishedPoolSettings(dataHandler: StakeDataHandler) {
        switch dataHandler.transferType {
        case .registerBaker:
            if case .open = dataHandler.getNewEntry(BakerPoolSettingsData.self)?.poolSettings {
                showComissionSettings(dataHandler: dataHandler)
            } else {
                showGenerateKey(dataHandler: dataHandler)
            }
        case .updateBakerPool:
            showComissionSettings(dataHandler: dataHandler)
        default:
            break
        }
        
    }
    
    func closedPoolSettings() {
        self.delegate?.finishedBakingCoordinator()
    }
}

extension BakingCoordinator: BakerPoolGenerateKeyPresenterDelegate {
    func shareExportedFile(url: URL, completion: @escaping (Bool) -> Void) {
        share(items: [url], from: navigationController, completion: completion)
    }
    
    func finishedGeneratingKeys(dataHandler: StakeDataHandler) {
        showRequestConfirmation(dataHandler: dataHandler)
    }
    
    func pressedClose() {
        delegate?.finishedBakingCoordinator()
    }
}

extension BakingCoordinator: BakerMetadataPresenterDelegate {
    func finishedMetadata(dataHandler: StakeDataHandler) {
        if case .updateBakerPool = dataHandler.transferType {
            showRequestConfirmation(dataHandler: dataHandler)
        } else {
            showGenerateKey(dataHandler: dataHandler)
        }
    }
    
    func closedMetadata() {
        delegate?.finishedBakingCoordinator()
    }
}

extension BakingCoordinator: BakerAmountInputPresenterDelegate {
    func finishedAmountInput(dataHandler: StakeDataHandler) {
        if case .updateBakerStake = dataHandler.transferType {
            showRequestConfirmation(dataHandler: dataHandler)
        } else {
            showPoolSettings(dataHandler: dataHandler)
        }
    }
    
    func switchToRemoveBaker() {
        showRequestConfirmation(
            dataHandler: BakerDataHandler(
                account: account,
                action: .stopBaking
            )
        )
    }
}

extension BakingCoordinator: BakerPoolReceiptConfirmationPresenterDelegate {
    func confirmedTransaction(transfer: TransferDataType, dataHandler: StakeDataHandler) {
        self.showSubmissionReceipt(transfer: transfer, dataHandler: dataHandler)
    }
}

extension BakingCoordinator: BakerPoolReceiptPresenterDelegate {
    func finishedShowingReceipt() {
        self.delegate?.finishedBakingCoordinator()
    }
}

extension BakingCoordinator: RequestPasswordDelegate {}

extension StorageManagerProtocol {
    func hasPendingBakerRegistration(for account: String) -> Bool {
        !getTransfers(for: account)
            .filter { $0.transferType.isBakingTransfer }
            .isEmpty
    }
}
