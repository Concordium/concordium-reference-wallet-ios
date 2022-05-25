//
//  BakerPoolReceiptPresenter.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 25/04/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

// MARK: Delegate
protocol BakerPoolReceiptPresenterDelegate: AnyObject {
    func finishedShowingReceipt()
    func pressedClose()
}

class BakerPoolReceiptPresenter: StakeReceiptPresenterProtocol {
    weak var view: StakeReceiptViewProtocol?
    weak var delegate: BakerPoolReceiptPresenterDelegate?
    
    private let account: AccountDataType
    private let viewModel: StakeReceiptViewModel
    private let transfer: TransferDataType
    private let receiptType: BakerPoolReceiptType
    
    private let storageManager: StorageManagerProtocol
    
    init(
        account: AccountDataType,
        delegate: BakerPoolReceiptPresenterDelegate? = nil,
        dependencyProvider: StakeCoordinatorDependencyProvider,
        dataHandler: StakeDataHandler,
        transfer: TransferDataType
    ) {
        self.account = account
        self.delegate = delegate
        self.viewModel = StakeReceiptViewModel(dataHandler: dataHandler)
        self.transfer = transfer
        self.receiptType = .init(dataHandler: dataHandler)
        self.storageManager = dependencyProvider.storageManager()
        
        self.viewModel.setup(
            with: receiptType,
            cost: GTU(intValue: Int(transfer.cost) ?? 0),
            transactionHash: transfer.submissionId ?? ""
        )
    }
    
    func viewDidLoad() {
        self.view?.bind(viewModel: viewModel)
    }
    
    private func alertOptions(for receiptType: BakerPoolReceiptType) -> AlertOptions {
        let finishAction = { (text: String) in
            AlertAction(name: text, completion: { [weak self] in
                self?.delegate?.finishedShowingReceipt()
            }, style: .default)
        }
        
        switch receiptType {
        case let .updateStake(isLoweringStake):
            if isLoweringStake {
                return AlertOptions(
                    title: "baking.receiptlowering.title".localized,
                    message: String(
                        format: "baking.receiptlowering.message".localized,
                        storageManager.getChainParams().formattedPoolOwnerCooldown
                    ),
                    actions: [finishAction("baking.receiptlowering.ok".localized)]
                )
            } else {
                return AlertOptions(
                    title: "baking.receiptupdatestake.title".localized,
                    message: "baking.receiptupdatestake.message".localized,
                    actions: [finishAction("baking.receiptupdatestake.ok".localized)]
                )
            }
        case .updatePool:
            return AlertOptions(
                title: "baking.receiptupdatepool.title".localized,
                message: "baking.receiptupdatepool.message".localized,
                actions: [finishAction("baking.receiptupdatepool.ok".localized)]
            )
        case .updateKeys:
            return AlertOptions(
                title: "baking.receiptupdatekeys.title".localized,
                message: "baking.receiptupdatekeys.message".localized,
                actions: [finishAction("baking.receiptupdatekeys.ok".localized)]
            )
        case .remove:
            return AlertOptions(
                title: "baking.receiptremove.title".localized,
                message: String(
                    format: "baking.receiptremove.message".localized,
                    storageManager.getChainParams().formattedPoolOwnerCooldown
                ),
                actions: [finishAction("baking.receiptremove.ok".localized)]
            )
        case .register:
            return AlertOptions(
                title: "baking.receiptregister.title".localized,
                message: "baking.receiptregister.message".localized,
                actions: [finishAction("baking.receiptregister.ok".localized)]
            )
        }
    }
    
    func pressedButton() {
        self.view?.showAlert(with: alertOptions(for: receiptType))
    }
    
    func closeButtonTapped() {
        self.delegate?.pressedClose()
    }
}

private extension Optional where Wrapped == ChainParametersEntity {
    var formattedPoolOwnerCooldown: String {
        let cooldown = GeneralFormatter.secondsToDays(seconds: self?.poolOwnerCooldown ?? 0)
        return String(format: "baking.cooldownperiod.format".localized, cooldown)
    }
}

private extension StakeReceiptViewModel {
    func setup(with type: BakerPoolReceiptType, cost: GTU, transactionHash: String) {
        showsBackButton = false
        receiptFooterText = transactionHash
        showsSubmitted = true
        text = nil
        buttonLabel = "stake.receipt.finish".localized
        transactionFeeText = String(format: "baking.receiptconfirmation.transactionfee".localized, cost.displayValueWithGStroke())
        switch type {
        case .updateStake:
            title = "baking.receiptconfirmation.title.updatestake".localized
            receiptHeaderText = "baking.receiptconfirmation.updatebakerstake".localized
        case .updatePool:
            title = "baking.receiptconfirmation.title.updatepool".localized
            receiptHeaderText = "baking.receiptconfirmation.updatebakerpool".localized
        case .updateKeys:
            title = "baking.receiptconfirmation.title.updatekeys".localized
            receiptHeaderText = "baking.receiptconfirmation.updatebakerkeys".localized
        case .remove:
            title = "baking.receiptconfirmation.title.remove".localized
            receiptHeaderText = "baking.receiptconfirmation.stopbaking".localized
        case .register:
            title = "baking.receiptconfirmation.title.register".localized
            receiptHeaderText = "baking.receiptconfirmation.registerbaker".localized
        }
    }
}
