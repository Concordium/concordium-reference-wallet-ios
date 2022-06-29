//
//  DelegationReceiptPresenter.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 14/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

// MARK: -
// MARK: Delegate
protocol DelegationReceiptPresenterDelegate: AnyObject {
    func finishedShowingReceipt()
    func pressedClose()
}

class DelegationReceiptPresenter: StakeReceiptPresenterProtocol {

    weak var view: StakeReceiptViewProtocol?
    weak var delegate: DelegationReceiptPresenterDelegate?
    var account: AccountDataType
    var viewModel: StakeReceiptViewModel
    
    private var dataHandler: StakeDataHandler
    private var cancellables = Set<AnyCancellable>()
    private var transfer: TransferDataType
    private var transactionsService: TransactionsServiceProtocol
    private var storageManager: StorageManagerProtocol
    
    init(account: AccountDataType,
         dependencyProvider: StakeCoordinatorDependencyProvider,
         delegate: DelegationReceiptPresenterDelegate? = nil,
         dataHandler: StakeDataHandler,
         transfer: TransferDataType) {
        self.account = account
        self.delegate = delegate
        self.dataHandler = dataHandler
        self.viewModel = StakeReceiptViewModel(dataHandler: dataHandler)
        self.transfer = transfer
        self.transactionsService = dependencyProvider.transactionsService()
        self.storageManager = dependencyProvider.storageManager()
        let isLoweringStake = dataHandler.isLoweringStake()
        self.viewModel.setup(isUpdate: dataHandler.hasCurrentData(),
                             isLoweringStake: isLoweringStake,
                             isRemoving: dataHandler.transferType == .removeDelegation,
                             transactionHash: transfer.submissionId ?? "",
                             cost: GTU(intValue: Int(transfer.cost) ?? 0))
    }

    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
    }
    
    func pressedButton() {
        let delegatorCooldown = storageManager.getChainParams()?.delegatorCooldown ?? 0
        let gracePeriod = String(
            format: "delegation.graceperiod.format".localized,
            GeneralFormatter.secondsToDays(seconds: delegatorCooldown)
        )
        
        let fineAction = { (label: String) in
            AlertAction(name: label, completion: { [weak self] in
                self?.delegate?.finishedShowingReceipt()
            }, style: .default)
        }
        
        if dataHandler.isLoweringStake() {
            let ok = "delegation.receiptlowering.ok".localized
            let title = "delegation.receiptlowering.title".localized
            
            let message = String(
                format: "delegation.receiptlowering.message".localized,
                gracePeriod
            )
            
            self.view?.showAlert(with: AlertOptions(
                title: title,
                message: message,
                actions: [fineAction(ok)]
            ))
        } else if dataHandler.transferType == .removeDelegation {
            let ok = "delegation.receiptremove.ok".localized
            let title = "delegation.receiptremove.title".localized
            
            let message = String(
                format: "delegation.receiptremove.message".localized,
                gracePeriod
            )
            
            self.view?.showAlert(with: AlertOptions(
                title: title,
                message: message,
                actions: [fineAction(ok)]
            ))
        } else {
            let ok = "delegation.receiptnextpayday.ok".localized
            let title = "delegation.receiptnextpayday.title".localized
            let message = "delegation.receiptnextpayday.message".localized
            
            self.view?.showAlert(with: AlertOptions(
                title: title,
                message: message,
                actions: [fineAction(ok)]
            ))
        }
    }
    
    func closeButtonTapped() {
        self.delegate?.pressedClose()
    }
}

fileprivate extension StakeReceiptViewModel {
    func setup(isUpdate: Bool, isLoweringStake: Bool, isRemoving: Bool, transactionHash: String, cost: GTU) {
        showsBackButton = false
        receiptFooterText = transactionHash
        showsSubmitted = true
        text = nil
        buttonLabel = "stake.receipt.finish".localized
        if isUpdate {
            title = "delegation.receiptconfirmation.title.update".localized
            receiptHeaderText = "delegation.receipt.updatedelegation".localized
        } else if isRemoving {
            title = "delegation.receiptconfirmation.title.remove".localized
            receiptHeaderText = "delegation.receipt.removedelegationheader".localized
        } else {
            title = "delegation.receiptconfirmation.title.create".localized
            receiptHeaderText = "delegation.receipt.registerdelegation".localized
        }
        transactionFeeText = String(format: "delegation.receiptconfirmation.transactionfee".localized, cost.displayValueWithGStroke())
    }
}
