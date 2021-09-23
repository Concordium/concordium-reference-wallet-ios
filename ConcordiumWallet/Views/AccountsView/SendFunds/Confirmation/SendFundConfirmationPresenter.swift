//
//  SendFundConfirmationPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 29/05/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import Combine

// MARK: View
protocol SendFundConfirmationViewProtocol: ShowError, Loadable {
    var line1Text: String? { get set }
    var line2Text: String? { get set }
    var line3Text: String? { get set }
    var line4Text: String? { get set }
    var line5Text: String? { get set }
    var buttonText: String? { get set }
    var visibleWaterMark: Bool { get set }
}

// MARK: -
// MARK: Delegate
protocol SendFundConfirmationPresenterDelegate: AnyObject {
    func sendFundSubmitted(transfer: TransferDataType, recipient: RecipientDataType)
    func sendFundFailed(error: Error)
}

// MARK: -
// MARK: Presenter
protocol SendFundConfirmationPresenterProtocol: AnyObject {
	var view: SendFundConfirmationViewProtocol? { get set }
    func viewDidLoad()
    func userTappedConfirm()
}

class SendFundConfirmationPresenter: SendFundConfirmationPresenterProtocol {

    weak var view: SendFundConfirmationViewProtocol?
    weak var delegate: (SendFundConfirmationPresenterDelegate & RequestPasswordDelegate)?
    let dependencyProvider: AccountsFlowCoordinatorDependencyProvider
    private var cancellables = [AnyCancellable]()

    private var amount: GTU
    private var fromAccount: AccountDataType
    private var recipient: RecipientDataType
    private var cost: GTU
    private var memo: Memo?
    private var energy: Int
    private var transferType: TransferType

    init(
        delegate: (SendFundConfirmationPresenterDelegate & RequestPasswordDelegate)? = nil,
        amount: GTU,
        from account: AccountDataType,
        to recipient: RecipientDataType,
        memo: Memo?,
        cost: GTU,
        energy: Int,
        dependencyProvider: AccountsFlowCoordinatorDependencyProvider,
        transferType: TransferType
    ) {
        self.delegate = delegate
        self.amount = amount
        self.fromAccount = account
        self.recipient = recipient
        self.cost = cost
        self.memo = memo
        self.energy = energy
        self.dependencyProvider = dependencyProvider
        self.transferType = transferType
    }

    func viewDidLoad() {
        let sAmount = amount.displayValueWithGStroke()
        let to = "sendFund.confirmation.line2.to".localized
        let recipientName = recipient.name
        if transferType == .encryptedTransfer || transferType == .simpleTransfer {
            view?.line2Text = "\(sAmount) \(to) \(recipientName)"
            let sFromAccount = "sendFund.confirmation.line3.fromAccount".localized
            let accountName = fromAccount.displayName
            view?.line3Text = "\(sFromAccount) \(accountName)"
        } else {
            view?.line2Text = "\(sAmount)"
            let sFromAccount = "sendFund.confirmation.line3.Account".localized
            let accountName = fromAccount.displayName
            view?.line3Text = "\(sFromAccount) \(accountName)"
        }
        
        view?.visibleWaterMark = false
        
        switch transferType {
        case .simpleTransfer:
            view?.line1Text = "sendFund.confirmation.transfer".localized
            view?.buttonText = "sendFund.confirmation.buttonTitle".localized
        case .encryptedTransfer:
            view?.line1Text = "sendFund.confirmation.transfer".localized
            view?.buttonText = "sendFund.sendshielded".localized
            view?.visibleWaterMark = true
        case .transferToPublic:
            view?.line1Text = "sendFund.confirmation.unshield".localized
            view?.buttonText = "accounts.unshieldedamount".localized
        case .transferToSecret:
            view?.line1Text = "sendFund.confirmation.shield".localized
            view?.buttonText = "accounts.shieldedamount".localized
            
        }

        let estimateTransactionFee = "sendFund.confirmation.line4.estimatedTransactionFee".localized
        let sCost = cost.displayValueWithGStroke()
        view?.line4Text = "\(estimateTransactionFee)\(sCost)"
        
        if let memo = memo?.memo {
            view?.line5Text = String(format: "sendFund.memo.text".localized, memo)
        } else {
            view?.line5Text = nil
        }
    }

    func userTappedConfirm() {
        var transfer = TransferDataTypeFactory.create()
        transfer.transferType = transferType
        transfer.amount = String(amount.intValue)
        transfer.fromAddress = fromAccount.address
        transfer.toAddress = recipient.address
        transfer.cost = String(cost.intValue)
//        transfer.memo = memo //TODO: FIXME
        transfer.energy = energy

        dependencyProvider.transactionsService()
                .performTransfer(transfer, from: fromAccount, requestPasswordDelegate: delegate!)
                .showLoadingIndicator(in: self.view)
                .tryMap(dependencyProvider.storageManager().storeTransfer)
                .sink(receiveError: { [weak self] error in
                    if case NetworkError.serverError = error {
                        Logger.error(error)
                        self?.delegate?.sendFundFailed(error: error)
                    } else if case GeneralError.userCancelled = error {
                        return
                    } else {
                        self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
                    }
                }, receiveValue: { [weak self] in
                    guard let self = self else { return }
                    Logger.debug($0)
                    self.delegate?.sendFundSubmitted(transfer: $0, recipient: self.recipient)
                }).store(in: &cancellables)
    }
}
