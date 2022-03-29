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
}


class DelegationReceiptPresenter: StakeReceiptPresenterProtocol {

    weak var view: StakeReceiptViewProtocol?
    weak var delegate: DelegationReceiptPresenterDelegate?
    var account: AccountDataType
    var viewModel : StakeReceiptViewModel
    
    private var dataHandler: StakeDataHandler
    private var cancellables = Set<AnyCancellable>()
    private var transfer: TransferDataType
    private var transactionsService: TransactionsServiceProtocol
    
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
        
        let isLoweringStake = dataHandler.isLoweringStake()
        self.viewModel.setup(isUpdate: dataHandler.hasCurrentData(), isLoweringStake: isLoweringStake, transactionHash: transfer.submissionId ?? "", cost: GTU(intValue: Int(transfer.cost) ?? 0))
    }

    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
    }
    
    func pressedButton() {
        if dataHandler.isLoweringStake() {
            let fineAction = AlertAction(name: "delegation.receiptlowering.ok".localized, completion: { [weak self] in
                self?.delegate?.finishedShowingReceipt()
            }, style: .default)
            //TODO: update grace period
            let alertOptions = AlertOptions(title: "delegation.receiptlowering.title".localized, message: String(format: "delegation.receiptlowering.message".localized, "<TBD>"), actions: [ fineAction])
            self.view?.showAlert(with: alertOptions)
        } else {
            self.delegate?.finishedShowingReceipt()
        }
    }
}

fileprivate extension StakeReceiptViewModel {
    func setup(isUpdate: Bool, isLoweringStake: Bool, transactionHash: String, cost: GTU) {
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
