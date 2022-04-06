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
                             transactionHash: transfer.submissionId ?? "",
                             cost: GTU(intValue: Int(transfer.cost) ?? 0))
    }

    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
    }
    
    func pressedButton() {
        let title: String
        let message: String
        let ok: String
        if dataHandler.isLoweringStake() {
            ok = "delegation.receiptlowering.ok".localized
            title = "delegation.receiptlowering.title".localized
            message = "delegation.receiptlowering.message".localized
        } else if dataHandler.transferType == .removeDelegation {
            ok = "delegation.receiptremove.ok".localized
            title = "delegation.receiptremove.title".localized
            message = "delegation.receiptremove.message".localized
        } else {
            ok = "delegation.receiptnextpayday.ok".localized
            title = "delegation.receiptnextpayday.title".localized
            message = "delegation.receiptnextpayday.message".localized
        }
        let fineAction = AlertAction(name: ok, completion: { [weak self] in
            self?.delegate?.finishedShowingReceipt()
        }, style: .default)
        let chainParams = self.storageManager.getChainParams()
        
        let gracePeriod = String(format:
                                    "delegation.graceperiod.format".localized,
                                 GeneralFormatter.secondsToDays(seconds: chainParams?.delegatorCooldown ?? 0))
        
        let alertOptions = AlertOptions(title: title,
                                        message: String(format: message.localized, gracePeriod),
                                        actions: [ fineAction])
        self.view?.showAlert(with: alertOptions)
    }
    
    func closeButtonTapped() {
        self.delegate?.pressedClose()
    }
}

fileprivate extension StakeReceiptViewModel {
    func setup(isUpdate: Bool, isLoweringStake: Bool, transactionHash: String, cost: GTU) {
        showsBackButton = false
        receiptFooterText = transactionHash
        showsSubmitted = true
        text = nil
        buttonLabel = "stake.receipt.finish".localized
        if isUpdate {
            title = "delegation.receiptconfirmation.title.update".localized
            receiptHeaderText = "delegation.receipt.updatedelegation".localized
        } else {
            title = "delegation.receiptconfirmation.title.create".localized
            receiptHeaderText = "delegation.receipt.registerdelegation".localized
        }
        transactionFeeText = String(format: "delegation.receiptconfirmation.transactionfee".localized, cost.displayValueWithGStroke())
    }
}
