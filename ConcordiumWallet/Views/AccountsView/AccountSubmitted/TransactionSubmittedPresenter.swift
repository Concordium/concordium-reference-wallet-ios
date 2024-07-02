//
//  TransactionSubmittedPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 4/16/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import Combine

class TransactionSubmittedViewModel {
    @Published var transferSummary: String
    @Published var visibleWaterMark: Bool
    @Published var submitedText: String
    @Published var amount: String
    @Published var recipient: RecipientDataType
    @Published var memoText: String?
    
    init(transfer: TransferDataType, recipient: RecipientDataType) {
        self.transferSummary = TransactionSubmittedViewModel.formatSummary(for: transfer)
        self.amount = GTU(intValue: Int(transfer.amount) ?? 0).displayValue()
        self.recipient = recipient
        
        self.visibleWaterMark = false
        
        if let memo = Memo(hex: transfer.memo) {
            self.memoText = String(format: "sendFund.memo.text".localized, memo.displayValue)
        }
        
        switch transfer.transferType {
        case .simpleTransfer:
            submitedText = "transactionConfirmed.submitted".localized
        case .registerBaker, .updateBakerKeys, .updateBakerPool, .updateBakerStake, .removeBaker, .configureBaker:
            submitedText = ""
        case .registerDelegation, .removeDelegation, .updateDelegation:
            submitedText = ""
        }
    }
    
    private static func formatSummary(for transfer: TransferDataType) -> String {
        let estimatedFee = GTU(intValue: Int(transfer.cost) ?? 0).displayValue()
        let summary = "sendFund.feeMessage".localized + estimatedFee
        return summary
    }
}

// MARK: View
protocol TransactionSubmittedViewProtocol: AnyObject {
    func bind(to viewModel: TransactionSubmittedViewModel)
}

// MARK: -
// MARK: Delegate
protocol TransactionSubmittedPresenterDelegate: AnyObject {
    func transactionSubmittedPresenterFinish()
}

// MARK: -
// MARK: Presenter
protocol TransactionSubmittedPresenterProtocol: AnyObject {
	var view: TransactionSubmittedViewProtocol? { get set }
    func viewDidLoad()
    
    func userTappedOk()
}

class TransactionSubmittedPresenter: TransactionSubmittedPresenterProtocol {

    weak var view: TransactionSubmittedViewProtocol?
    weak var delegate: TransactionSubmittedPresenterDelegate?
    
    private var viewModel: TransactionSubmittedViewModel

    init(transfer: TransferDataType, recipient: RecipientDataType, delegate: TransactionSubmittedPresenterDelegate? = nil) {
        viewModel = TransactionSubmittedViewModel(transfer: transfer, recipient: recipient)
        self.delegate = delegate
    }

    func viewDidLoad() {
        view?.bind(to: viewModel)
    }
    
    func userTappedOk() {
        delegate?.transactionSubmittedPresenterFinish()
    }
}
