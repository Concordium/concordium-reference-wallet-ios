//
//  BakerPoolReceiptConfirmationPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 25/04/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

// MARK: Delegate
protocol BakerPoolReceiptConfirmationPresenterDelegate: AnyObject {
    func confirmedTransaction(transfer: TransferDataType)
    func pressedClose()
}

class BakerPoolReceiptConfirmationPresenter: StakeReceiptPresenterProtocol {
    typealias Delegate = BakerPoolReceiptConfirmationPresenterDelegate & RequestPasswordDelegate
    
    weak var view: StakeReceiptViewProtocol?
    weak var delegate: Delegate?
    
    private let account: AccountDataType
    private let viewModel: StakeReceiptViewModel
    private let dataHandler: StakeDataHandler
    private let transactionService: TransactionsServiceProtocol
    private let storageManager: StorageManagerProtocol
    
    private let cost: GTU
    private let energy: Int
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        account: AccountDataType,
        dependencyProvider: StakeCoordinatorDependencyProvider,
        delegate: Delegate?,
        cost: GTU,
        energy: Int,
        dataHandler: StakeDataHandler
    ) {
        self.account = account
        self.delegate = delegate
        self.dataHandler = dataHandler
        self.viewModel = StakeReceiptViewModel(dataHandler: dataHandler)
        self.transactionService = dependencyProvider.transactionsService()
        self.storageManager = dependencyProvider.storageManager()
        
        self.cost = cost
        self.energy = energy
        
        self.viewModel.setup(with: .init(dataHandler: dataHandler), cost: cost)
    }
    
    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
    }
    
    func pressedButton() {
        guard let delegate = delegate else {
            return
        }
        
        var transfer = dataHandler.getTransferObject()
        transfer.fromAddress = account.address
        transfer.cost = String(cost.intValue)
        transfer.energy = energy
        
        self.transactionService.performTransfer(transfer, from: account, requestPasswordDelegate: delegate)
            .showLoadingIndicator(in: view)
            .tryMap(self.storageManager.storeTransfer(_:))
            .sink { error in
                self.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
            } receiveValue: { transfer in
                self.delegate?.confirmedTransaction(transfer: transfer)
            }.store(in: &cancellables)
    }
    
    func closeButtonTapped() {
        self.delegate?.pressedClose()
    }
}

private extension StakeReceiptViewModel {
    func setup(with type: BakerPoolReceiptType, cost: GTU) {
        receiptFooterText = nil
        showsSubmitted = false
        transactionFeeText = String(format: "baking.receiptconfirmation.transactionfee".localized, cost.displayValueWithGStroke())
        
        switch type {
        case let .updateStake(isLoweringStake):
            title = "baking.receiptconfirmation.title.updatestake".localized
            receiptHeaderText = "baking.receiptconfirmation.updatebakerstake".localized
            if isLoweringStake {
                text = "baking.receiptconfirmation.loweringstake".localized
            } else {
                text = nil
            }
        case .updatePool:
            title = "baking.receiptconfirmation.title.updatepool".localized
            receiptHeaderText = "baking.receiptconfirmation.updatebakerpool".localized
            text = nil
        case .updateKeys:
            title = "baking.receiptconfirmation.title.updatekeys".localized
            receiptHeaderText = "baking.receiptconfirmation.updatebakerkeys".localized
            text = nil
        case .remove:
            title = "baking.receiptconfirmation.title.remove".localized
            text = "baking.receiptconfirmation.removetext".localized
            receiptHeaderText = "baking.receiptconfirmation.stopbaking".localized
        case .register:
            title = "baking.receiptconfirmation.title.register".localized
            text = "baking.receiptconfirmation.registertext".localized
            receiptHeaderText = "baking.receiptconfirmation.registerbaker".localized
        }
    }
}
