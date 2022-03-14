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
    private var transactionsService: TransactionsServiceProtocol
    
    init(account: AccountDataType, dependencyProvider: StakeCoordinatorDependencyProvider, delegate: DelegationReceiptPresenterDelegate? = nil, dataHandler: StakeDataHandler) {
        self.account = account
        self.delegate = delegate
        self.dataHandler = dataHandler
        self.viewModel = StakeReceiptViewModel(dataHandler: dataHandler)
        
        self.transactionsService = dependencyProvider.transactionsService()
        
        let isLoweringStake = dataHandler.isLoweringStake()
        //TODO: fill in grace period
        self.viewModel.setup(isUpdate: dataHandler.hasCurrentData(), isLoweringStake: isLoweringStake, transactionHash: "[[[transction HASH]]]")
    }

    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
        
//        transactionsService.getTransferCost(transferType: TransferType, memoSize: <#T##Int?#>)
        //setup transaction fee -> "delegation.receipt.transactionfee"
    }
    
    func pressedButton() {
        self.delegate?.finishedShowingReceipt()
    }
}



fileprivate extension StakeReceiptViewModel {
    func setup(isUpdate: Bool, isLoweringStake: Bool, transactionHash: String) {
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
    }
}
