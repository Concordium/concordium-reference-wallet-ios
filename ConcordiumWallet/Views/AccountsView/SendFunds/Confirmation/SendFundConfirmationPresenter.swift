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
protocol SendFundConfirmationViewProtocol: ShowAlert, Loadable {
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
    func sendFundSubmitted(transfer: TransferDataType, recipient: RecipientDataType, amount: SendFundsAmount)
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

    private var amount: SendFundsAmount
    private var fromAccount: AccountDataType
    private var recipient: RecipientDataType
    private var cost: GTU
    private var memo: Memo?
    private var energy: Int
    private var transferType: SendFundTransferType
    private var tokenType: SendFundsTokenType
    init(
        delegate: (SendFundConfirmationPresenterDelegate & RequestPasswordDelegate)? = nil,
        amount: SendFundsAmount,
        from account: AccountDataType,
        to recipient: RecipientDataType,
        memo: Memo?,
        cost: GTU,
        energy: Int,
        dependencyProvider: AccountsFlowCoordinatorDependencyProvider,
        transferType: SendFundTransferType,
        tokenType: SendFundsTokenType
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
        self.tokenType = tokenType
    }

    func viewDidLoad() {
        var sAmount = amount.displayValue
        let to = "sendFund.confirmation.line2.to".localized
        let recipientName = recipient.displayName()
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
        case .simpleTransfer, .contractUpdate:
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
        
        if let memo = memo?.displayValue {
            view?.line5Text = String(format: "sendFund.memo.text".localized, memo)
        } else {
            view?.line5Text = nil
        }
    }

    func userTappedConfirm() {
        var transfer = TransferDataTypeFactory.create()
        transfer.transferType = transferType.actualType
        transfer.fromAddress = fromAccount.address
        transfer.toAddress = recipient.address
        transfer.amount = String(amount.intValue)
        transfer.energy = energy
        transfer.cost = String(cost.intValue)
        transfer.memo = memo?.data.hexDescription
        if transferType.actualType == .contractUpdate, case let SendFundsTokenType.cis2(token: token) = tokenType {
            let response = try? dependencyProvider.mobileWallet().serializeTokenTransferParameters(
                input: .init(
                    tokenId: token.tokenId,
                    amount: "\(amount.intValue)",
                    from: fromAccount.address,
                    to: recipient.address
                )
            )
            transfer.payload = .contractUpdatePayload(
                .init(
                    amount: "0",
                    address: .init(index: Int(token.contractIndex) ?? 0, subindex: 0),
                    receiveName: token.contractName + ".transfer",
                    maxContractExecutionEnergy: energy,
                    message: response?.parameter ?? ""
                )
            )
        } 
        dependencyProvider.transactionsService()
            .performTransfer(transfer, from: fromAccount, requestPasswordDelegate: delegate!)
            .showLoadingIndicator(in: view)
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
                self.delegate?.sendFundSubmitted(transfer: $0, recipient: self.recipient, amount: self.amount)
            })
            .store(in: &cancellables)
    }
}
