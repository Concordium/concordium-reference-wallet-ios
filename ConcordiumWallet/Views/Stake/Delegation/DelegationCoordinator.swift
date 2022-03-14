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
    
    init(navigationController: UINavigationController, dependencyProvider: StakeCoordinatorDependencyProvider, account: AccountDataType, parentCoordinator: DelegationCoordinatorDelegate) {
        self.navigationController = navigationController
        self.dependencyProvider = dependencyProvider
        self.account = account
        self.delegate = parentCoordinator
        //TODO: figure out from account whether we are editing or registering
        self.delegationDataHandler = StakeDataHandler(transactionType: .registerDelegation)
    }
    
    func start() {
        showAmountInput()
    }
    
    func showAmountInput() {
        let presenter = DelegationAmountInputPresenter(account: account, delegate: self, dataHandler: delegationDataHandler)
        let vc = StakeAmountInputFactory.create(with: presenter)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showPoolSelection() {
        let presenter = DelegationPoolSelectionPresenter(delegate: self, dataHandler: delegationDataHandler)
        let vc = DelegationPoolSelectionFactory.create(with: presenter)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showConfirmation() {
        let presenter = DelegationReceiptConfirmationPresenter(account: account, dependencyProvider: dependencyProvider, delegate: self, dataHandler: delegationDataHandler)
        let vc = StakeReceiptFactory.create(with: presenter)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showSubmissionReceipt() {
        let presenter = DelegationReceiptPresenter(account: account, dependencyProvider: dependencyProvider, delegate: self, dataHandler: delegationDataHandler)
        let vc = StakeReceiptFactory.create(with: presenter)
        navigationController.pushViewController(vc, animated: true)
    }
}

extension DelegationCoordinator: DelegationAmountInputPresenterDelegate {
    func finishedDelegation() {
        self.delegate?.finished()
    }
    func finishedAmountInput() {
        self.showPoolSelection()
    }
}

extension DelegationCoordinator: DelegationPoolSelectionPresenterDelegate {
    func finishedPoolSelection() {
        self.showConfirmation()
    }
}

extension DelegationCoordinator: DelegationReceiptConfirmationPresenterDelegate {
    func confirmedTransaction() {
        self.showSubmissionReceipt()
    }
}

extension DelegationCoordinator: DelegationReceiptPresenterDelegate {
    func finishedShowingReceipt() {
        self.navigationController.popToRootViewController(animated: true)
    }
}
