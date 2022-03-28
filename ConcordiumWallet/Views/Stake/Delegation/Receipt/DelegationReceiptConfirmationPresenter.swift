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
    func confirmedTransaction()
}


class DelegationReceiptConfirmationPresenter: StakeReceiptPresenterProtocol {

    weak var view: StakeReceiptViewProtocol?
    weak var delegate: (DelegationReceiptConfirmationPresenterDelegate & RequestPasswordDelegate)?
    var account: AccountDataType
    var viewModel : StakeReceiptViewModel
    
    private var cost: GTU
    private var energy: Int
    
    private var dataHandler: StakeDataHandler
    private var transactionsService: TransactionsServiceProtocol
    private var stakeService: StakeServiceProtocol
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
        let isLoweringStake = dataHandler.isLoweringStake()
        //TODO: fill in grace period
        self.viewModel.setup(isUpdate: dataHandler.hasCurrentData(), isLoweringStake: isLoweringStake, gracePeriod: "[[<current grace period>]]")
    }

    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
        
        //setup transaction fee -> "delegation.receiptconfirmation.transactionfee"
        
    }
    func pressedButton() {
        guard let delegate = delegate else {
            return
        }

        var transfer = dataHandler.getTransferObject()
        transfer.fromAddress = account.address
        transfer.cost = String(cost.intValue)
        transfer.energy = energy
        
        self.transactionsService.performTransfer(transfer, from: account, requestPasswordDelegate: delegate)
            .sink { error in
                self.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
            } receiveValue: { [weak self] transfer in
                self?.delegate?.confirmedTransaction()
            }.store(in: &cancellables)
    }
}

fileprivate extension StakeReceiptViewModel {
    func setup(isUpdate: Bool, isLoweringStake: Bool, gracePeriod: String) {
        receiptFooterText = nil
        showsSubmitted = false
        buttonLabel = "delegation.receiptconfirmation.submit".localized
        if isUpdate {
            title = "delegation.receiptconfirmation.title.update".localized
            if isLoweringStake {
                text = String(format: "delegation.receiptconfirmation.loweringstake".localized, gracePeriod)
            } else {
                text = ""
            }
            receiptHeaderText = "delegation.receipt.updatedelegation".localized
        } else {
            title = "delegation.receiptconfirmation.title.create".localized
            receiptHeaderText = "delegation.receipt.registerdelegation".localized
            text = String(format: "delegation.receiptconfirmation.registertext".localized, gracePeriod)
        }
    }
}
