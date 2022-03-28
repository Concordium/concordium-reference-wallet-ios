//
//  StakeCoordinator.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 03/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import UIKit

protocol DelegationCoordinatorDelegate: Coordinator {
    func finished()
}

class DelegationCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    weak var delegate: DelegationCoordinatorDelegate?
    private var account: AccountDataType
    
    private var dependencyProvider: StakeCoordinatorDependencyProvider
    private var delegationDataHandler: StakeDataHandler
    
    init(navigationController: UINavigationController,
         dependencyProvider: StakeCoordinatorDependencyProvider,
         account: AccountDataType,
         parentCoordinator: DelegationCoordinatorDelegate) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .fullScreen
        self.dependencyProvider = dependencyProvider
        self.account = account
        self.delegate = parentCoordinator
        self.delegationDataHandler = DelegationDataHandler(account: account, isRemoving: false)
    }
    
    func start() {
        // if we have delegation we go to status
        if account.delegation != nil {
            showStatus()
            return
        }
        
        // if we don't have delegation, we check whether there is a pending transaction for delegation
        let transfers = self.dependencyProvider.storageManager().getTransfers(for: account.address).filter { transfer in
            transfer.transferType == .removeDelegation || transfer.transferType == .updateDelegation || transfer.transferType == .registerDelegation
        }
        
        if transfers.count > 0 {
            self.showStatus()
        } else {
            self.showCarousel(mode: .register)
        }
    }
    
    func showCarousel(mode: DelegationOnboardingMode) {
        let onboardingDelegator = DelegationOnboardingCoordinator(navigationController: navigationController, parentCoordinator: self, mode: mode)
        childCoordinators.append(onboardingDelegator)
        onboardingDelegator.start()
    }

    func showStatus() {
        let presenter = DelegationStatusPresenter(account: account,
                                                  dataHandler: delegationDataHandler,
                                                  dependencyProvider: dependencyProvider,
                                                  delegate: self)
        let vc = StakeStatusFactory.create(with: presenter)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func stopDelegation(cost: GTU, energy: Int) {
        self.delegationDataHandler = DelegationDataHandler(account: account, isRemoving: true)
        showRequestConfirmation(cost: cost, energy: energy)
    }
      
    func showAmountInput(bakerPoolResponse: BakerPoolResponse?) {
        let presenter = DelegationAmountInputPresenter(account: account,
                                                       delegate: self,
                                                       dependencyProvider: dependencyProvider,
                                                       dataHandler: delegationDataHandler,
                                                       bakerPoolResponse: bakerPoolResponse)
        let vc = StakeAmountInputFactory.create(with: presenter)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showPoolSelection() {
        let presenter = DelegationPoolSelectionPresenter(
            account: account,
            delegate: self,
            dependencyProvider: dependencyProvider,
            dataHandler: delegationDataHandler
        )
        let vc = DelegationPoolSelectionFactory.create(with: presenter)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showRequestConfirmation(cost: GTU,
                                 energy: Int) {
        let presenter = DelegationReceiptConfirmationPresenter(account: account,
                                                               dependencyProvider: dependencyProvider,
                                                               delegate: self,
                                                               cost: cost,
                                                               energy: energy,
                                                               dataHandler: delegationDataHandler)
        let vc = StakeReceiptFactory.create(with: presenter)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showSubmissionReceipt(transfer: TransferDataType) {
        let presenter = DelegationReceiptPresenter(account: account,
                                                   dependencyProvider: dependencyProvider,
                                                   delegate: self,
                                                   dataHandler: delegationDataHandler,
                                                   transfer: transfer)
        let vc = StakeReceiptFactory.create(with: presenter)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showUpdateDelegation() {
        self.delegationDataHandler = DelegationDataHandler(account: account, isRemoving: false)
        showPoolSelection()
    }
    
    func cleanup() {
        childCoordinators.removeAll(where: { $0 is DelegationOnboardingCoordinator })
        self.delegate?.finished()
    }
}

extension DelegationCoordinator: DelegationAmountInputPresenterDelegate {
    func switchToRemoveDelegator(cost: GTU, energy: Int) {
        stopDelegation(cost: cost, energy: energy)
        self.navigationController.viewControllers = self.navigationController.viewControllers.filter {
            !($0 is StakeAmountInputViewController || $0 is DelegationPoolSelectionViewController)
        }
    }

    func finishedAmountInput(cost: GTU, energy: Int) {
        self.showRequestConfirmation(cost: cost, energy: energy)
    }
}

extension DelegationCoordinator: DelegationPoolSelectionPresenterDelegate {
    func finishedPoolSelection(bakerPoolResponse: BakerPoolResponse?) {
        showAmountInput(bakerPoolResponse: bakerPoolResponse)
    }
}

extension DelegationCoordinator: DelegationReceiptConfirmationPresenterDelegate {
    func confirmedTransaction(transfer: TransferDataType) {
        self.showSubmissionReceipt(transfer: transfer)
    }
}

extension DelegationCoordinator: DelegationReceiptPresenterDelegate {
    func finishedShowingReceipt() {
        cleanup()
        self.delegate?.finished()
    }
}

extension DelegationCoordinator: RequestPasswordDelegate {
}

extension DelegationCoordinator: DelegationStatusPresenterDelegate {
    func pressedClose() {
        cleanup()
        self.delegate?.finished()
    }
    
    func pressedStop(cost: GTU, energy: Int) {
        showCarousel(mode: .remove(cost: cost, energy: energy))
    }
    func pressedRegisterOrUpdate() {
        showCarousel(mode: .update)
    }
}

extension DelegationCoordinator: DelegationOnboardingCoordinatorDelegate {
    func finished(mode: DelegationOnboardingMode) {
        switch mode {
        case .register:
            showPoolSelection()
        case .update:
            showUpdateDelegation()
        case .remove(let cost, let energy):
            stopDelegation(cost: cost, energy: energy)
        }
    }
    
    func closed() {
        cleanup()
        self.delegate?.finished()
    }
}

extension DelegationCoordinator: RequestPasswordDelegate {
    
}
