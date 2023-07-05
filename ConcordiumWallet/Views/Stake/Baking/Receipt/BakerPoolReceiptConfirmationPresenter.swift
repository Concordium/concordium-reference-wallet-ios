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
    func confirmedTransaction(transfer: TransferDataType, dataHandler: StakeDataHandler)
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
    
    private var cost: GTU?
    private var energy: Int?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        account: AccountDataType,
        dependencyProvider: StakeCoordinatorDependencyProvider,
        delegate: Delegate?,
        dataHandler: StakeDataHandler
    ) {
        self.account = account
        self.delegate = delegate
        self.dataHandler = dataHandler
        self.viewModel = StakeReceiptViewModel(dataHandler: dataHandler)
        self.transactionService = dependencyProvider.transactionsService()
        self.storageManager = dependencyProvider.storageManager()
        
        self.viewModel.setup(with: .init(dataHandler: dataHandler))
    }
    
    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
        
        transactionService
            .getTransferCost(
                transferType: dataHandler.transferType.toWalletProxyTransferType(),
                costParameters: dataHandler.getCostParameters()
            )
            .showLoadingIndicator(in: view)
            .sink { [weak self] error in
                self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
            } receiveValue: { [weak self] transferCost in
                let cost = GTU(intValue: Int(transferCost.cost) ?? 0)
                self?.cost = cost
                self?.energy = transferCost.energy
                self?.viewModel.transactionFeeText = String(
                    format: "baking.receiptconfirmation.transactionfee".localized,
                    cost.displayValueWithGStroke()
                )
                self?.displayFeeWarningIfNeeded()
            }
            .store(in: &cancellables)

    }
    
    func pressedButton() {
        guard let delegate = delegate, let cost = cost, let energy = energy else {
            return
        }
        
        let transfer = dataHandler.getTransferObject(cost: cost, energy: energy)
        
        self.transactionService.performTransfer(
            transfer,
            from: account,
            bakerKeys: dataHandler.getNewEntry(BakerKeyData.self)?.keys,
            requestPasswordDelegate: delegate
        )
            .showLoadingIndicator(in: view)
            .tryMap(self.storageManager.storeTransfer(_:))
            .sink(receiveError: { error in
                if !GeneralError.isGeneralError(.userCancelled, error: error) {
                    self.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
                }
            }, receiveValue: { transfer in
                self.delegate?.confirmedTransaction(transfer: transfer, dataHandler: self.dataHandler)
            }).store(in: &cancellables)
    }
    
    func closeButtonTapped() {
        self.delegate?.pressedClose()
    }
    
    private func displayFeeWarningIfNeeded() {
        let atDisposal = GTU(intValue: account.forecastAtDisposalBalance)
        if let cost = cost, cost > atDisposal {
            self.view?.showAlert(
                with: AlertOptions(
                    title: "baking.receiptconfirmation.feewarning.title".localized,
                    message: "baking.receiptconfirmation.feewarning.message".localized,
                    actions: [
                        .init(
                            name: "baking.receiptconfirmation.feewarning.ok".localized,
                            completion: nil,
                            style: .default
                        )
                    ]
                )
            )
        }
    }
}

private extension StakeReceiptViewModel {
    func setup(with type: BakerPoolReceiptType) {
        receiptFooterText = nil
        showsSubmitted = false
        buttonLabel = "baking.receiptconfirmation.submit".localized
        
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
