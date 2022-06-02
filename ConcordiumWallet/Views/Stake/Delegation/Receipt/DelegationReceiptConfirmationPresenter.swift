//
//  DelegationReceiptConfirmationPresenter.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 14/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

// MARK: -
// MARK: Delegate
protocol DelegationReceiptConfirmationPresenterDelegate: AnyObject {
    func confirmedTransaction(dataHandler: StakeDataHandler, transfer: TransferDataType)
    func pressedClose() 
}

class DelegationReceiptConfirmationPresenter: StakeReceiptPresenterProtocol {

    weak var view: StakeReceiptViewProtocol?
    weak var delegate: (DelegationReceiptConfirmationPresenterDelegate & RequestPasswordDelegate)?
    var account: AccountDataType
    var viewModel: StakeReceiptViewModel
    
    private var cost: GTU
    private var energy: Int
    
    private var dataHandler: StakeDataHandler
    private var transactionsService: TransactionsServiceProtocol
    private var stakeService: StakeServiceProtocol
    private var storeManager: StorageManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(account: AccountDataType,
         dependencyProvider: StakeCoordinatorDependencyProvider,
         delegate: (DelegationReceiptConfirmationPresenterDelegate & RequestPasswordDelegate)?,
         cost: GTU,
         energy: Int,
         dataHandler: StakeDataHandler) {
        self.account = account
        self.cost = cost
        self.energy = energy
        self.delegate = delegate
        self.dataHandler = dataHandler
        self.viewModel = StakeReceiptViewModel(dataHandler: dataHandler)
        self.transactionsService = dependencyProvider.transactionsService()
        self.stakeService = dependencyProvider.stakeService()
        self.storeManager = dependencyProvider.storageManager()
        let isLoweringStake = dataHandler.isLoweringStake()
        let chainParams = self.storeManager.getChainParams()
        self.viewModel.setup(isUpdate: dataHandler.hasCurrentData(),
                             isLoweringStake: isLoweringStake,
                             gracePeriod: chainParams?.delegatorCooldown ?? 0,
                             transferCost: cost,
                             isRemoving: dataHandler.transferType == .removeDelegation)
    }

    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
    }
    func pressedButton() {
        guard let delegate = delegate else {
            return
        }

        let transfer = dataHandler.getTransferObject(cost: cost, energy: energy)
        
        self.transactionsService.performTransfer(transfer, from: account, requestPasswordDelegate: delegate)
            .showLoadingIndicator(in: view)
            .tryMap(self.storeManager.storeTransfer)
            .sink(receiveError: { error in
                if case GeneralError.userCancelled = error { return }
                self.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
            }, receiveValue: { [weak self] transfer in
                if let self = self {
                    self.delegate?.confirmedTransaction(
                        dataHandler: self.dataHandler,
                        transfer: transfer
                    )
                }
            }).store(in: &cancellables)
    }
    func closeButtonTapped() {
        self.delegate?.pressedClose()
    }
}

fileprivate extension StakeReceiptViewModel {
    func setup(isUpdate: Bool, isLoweringStake: Bool, gracePeriod: Int, transferCost: GTU, isRemoving: Bool) {
        receiptFooterText = nil
        showsSubmitted = false
        let gracePeriod = String(format: "delegation.graceperiod.format".localized, GeneralFormatter.secondsToDays(seconds: gracePeriod))
        
        buttonLabel = "delegation.receiptconfirmation.submit".localized
        if isUpdate {
            title = "delegation.receiptconfirmation.title.update".localized
            if isLoweringStake {
                text = String(format: "delegation.receiptconfirmation.loweringstake".localized, gracePeriod)
            } else {
                text = "delegation.receiptconfirmation.updatetext".localized
            }
            receiptHeaderText = "delegation.receipt.updatedelegation".localized
        } else if isRemoving {
            title = "delegation.receiptconfirmation.title.remove".localized
            text = "delegation.receipt.removedelegation".localized
            receiptHeaderText = "delegation.receipt.removedelegationheader".localized
        } else {
            title = "delegation.receiptconfirmation.title.create".localized
            receiptHeaderText = "delegation.receipt.registerdelegation".localized
            text = String(format: "delegation.receiptconfirmation.registertext".localized, gracePeriod)
        }
        transactionFeeText = String(format: "delegation.receiptconfirmation.transactionfee".localized, transferCost.displayValueWithGStroke())
    }
}
