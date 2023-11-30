//
// Created by Concordium on 16/04/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import SwiftUI
import UIKit

protocol SendFundsCoordinatorDelegate: AnyObject {
    func sendFundsCoordinatorFinished()
}

enum SendFundTransferType {
    case simpleTransfer
    case encryptedTransfer
    case transferToSecret
    case transferToPublic
    case contractUpdate
    var actualType: TransferType {
        switch self {
        case .simpleTransfer:
            return .simpleTransfer
        case .encryptedTransfer:
            return .encryptedTransfer
        case .transferToSecret:
            return .transferToSecret
        case .transferToPublic:
            return .transferToPublic
        case .contractUpdate:
            return .contractUpdate
        }
    }
}

enum SendFundsTokenType: Equatable {
    case ccd
    case cis2(token: CIS2TokenSelectionRepresentable)
}

class SendFundsCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    weak var parentCoordinator: SendFundsCoordinatorDelegate?

    var navigationController: UINavigationController
    private var account: AccountDataType
    private var balanceType: AccountBalanceTypeEnum
    private var transferType: SendFundTransferType
    private var dependencyProvider: AccountsFlowCoordinatorDependencyProvider
    var sendFundPresenter: SendFundPresenter?
    var tokenType: SendFundsTokenType
    init(navigationController: UINavigationController,
         delegate: SendFundsCoordinatorDelegate,
         dependencyProvider: AccountsFlowCoordinatorDependencyProvider,
         account: AccountDataType,
         balanceType: AccountBalanceTypeEnum,
         transferType: SendFundTransferType,
         tokenType: SendFundsTokenType
    ) {
        self.account = account
        self.balanceType = balanceType
        self.transferType = transferType
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .fullScreen
        parentCoordinator = delegate
        self.tokenType = tokenType
        self.dependencyProvider = dependencyProvider
    }

    func start() {
        let sendFundPresenter = SendFundPresenter(account: account,
                                                  balanceType: balanceType,
                                                  transferType: transferType,
                                                  dependencyProvider: dependencyProvider,
                                                  delegate: self,
                                                  tokenType: tokenType
        )
        self.sendFundPresenter = sendFundPresenter
        let sendFundVC = SendFundFactory.create(with: sendFundPresenter)
        navigationController.viewControllers = [sendFundVC]
    }

    func showSelectRecipient(balanceType: AccountBalanceTypeEnum, currentAccount: AccountDataType) {
        let mode: SelectRecipientMode
        if balanceType == .shielded {
            mode = .selectRecipientFromShielded
        } else {
            mode = .selectRecipientFromPublic
        }
        let vc = SelectRecipientFactory.create(with: SelectRecipientPresenter(delegate: self,
                                                                              storageManager: dependencyProvider.storageManager(),
                                                                              mode: mode,
                                                                              ownAccount: currentAccount))
        navigationController.pushViewController(vc, animated: true)
    }

    func showAddMemo(_ memo: Memo?) {
        let addMemoPresenter = AddMemoPresenter(delegate: self, memo: memo)
        let addMemoViewController = AddMemoFactory.create(with: addMemoPresenter)
        navigationController.pushViewController(addMemoViewController, animated: true)
    }

    func showAddRecipient() {
        let vc = AddRecipientFactory.create(with: AddRecipientPresenter(delegate: self, dependencyProvider: dependencyProvider, mode: .add))
        navigationController.pushViewController(vc, animated: true)
    }

    func showTransactionSubmitted(transfer: TransferDataType, recipient: RecipientDataType) {
        let vc = TransactionSubmittedFactory.create(with: TransactionSubmittedPresenter(transfer: transfer, recipient: recipient, delegate: self))
        showModally(vc, from: navigationController)
    }

    func showTransferFailed(error: Error) {
        let vc = CreationFailedFactory.create(with: CreationFailedPresenter(serverError: error, delegate: self, mode: .transfer))
        showModally(vc, from: navigationController)
    }

    func showScanAddressQR(didScanQRCode: @escaping ((String) -> Void)) {
        let vc = ScanQRViewControllerFactory.create(
            with: ScanQRPresenter(
                didScanQrCode: { address in
                    // Decorate the callback by adding validation.
                    if !self.dependencyProvider.mobileWallet().check(accountAddress: address) {
                        return false
                    }
                    didScanQRCode(address)
                    return true
                }
            )
        )
        navigationController.pushViewController(vc, animated: true)
    }

    func showSendFundConfirmation(
        amount: SendFundsAmount,
        energy: Int,
        from account: AccountDataType,
        to recipient: RecipientDataType,
        memo: Memo?,
        cost: GTU,
        transferType: SendFundTransferType
    ) {
        let presenter = SendFundConfirmationPresenter(
            delegate: self,
            amount: amount,
            from: account,
            to: recipient,
            memo: memo,
            cost: cost,
            energy: energy,
            dependencyProvider: dependencyProvider,
            transferType: transferType,
            tokenType: tokenType
        )
        let vc = SendFundConfirmationFactory.create(with: presenter)
        navigationController.pushViewController(vc, animated: true)
    }

    func selectedRecipient(_ recipient: RecipientDataType) {
        guard let vc = sendFundPresenter?.view as? UIViewController else { return }
        navigationController.popToViewController(vc, animated: true)

        // Pass the data to the send fund presenter
        sendFundPresenter?.setSelectedRecipient(recipient: recipient)
    }

    func addedMemo(_ memo: Memo) {
        guard let vc = sendFundPresenter?.view as? UIViewController else { return }
        navigationController.popToViewController(vc, animated: true)
        sendFundPresenter?.setAddedMemo(memo: memo)
    }
}

extension SendFundsCoordinator: SendFundPresenterDelegate {
    func sendFundPresenter(_ presenter: SendFundPresenter, didUpdate sendFundsTokenType: SendFundsTokenType) {
        self.tokenType = sendFundsTokenType
    }
    
    func sendFundPresenterShowScanQRCode(didScanQRCode: @escaping ((String) -> Void)) {
        showScanAddressQR(didScanQRCode: didScanQRCode)
    }

    func sendFundPresenterShowTokenTypeSelector(didSelectToken: @escaping ((CIS2TokenSelectionRepresentable?) -> Void)) {
        navigationController.present(
            UIHostingController(
                rootView:
                SendFundTokenSelection(
                    service: dependencyProvider.cis2Service(),
                    account: account,
                    didSelectToken: { [weak self] token in
                        didSelectToken(token)
                        self?.navigationController.dismiss(animated: true)
                    }
                )
            ),
            animated: true
        )
    }

    func sendFundPresenter(
        didSelectTransferAmount amount: SendFundsAmount,
        energyUsed energy: Int,
        from account: AccountDataType,
        to recipient: RecipientDataType,
        memo: Memo?,
        cost: GTU,
        transferType: SendFundTransferType
    ) {
        showSendFundConfirmation(
            amount: amount,
            energy: energy,
            from: account,
            to: recipient,
            memo: memo,
            cost: cost,
            transferType: transferType
        )
    }

    func sendFundPresenterAddMemo(_ presenter: SendFundPresenter, memo: Memo?) {
        showAddMemo(memo)
    }

    func sendFundPresenterSelectRecipient(_ presenter: SendFundPresenter, balanceType: AccountBalanceTypeEnum, currentAccount: AccountDataType) {
        showSelectRecipient(balanceType: balanceType, currentAccount: currentAccount)
    }

    func sendFundPresenterClosed(_ presenter: SendFundPresenter) {
        parentCoordinator?.sendFundsCoordinatorFinished()
    }

    func dismissQR() {
        navigationController.popViewController(animated: true)
    }
}

extension SendFundsCoordinator: AddMemoPresenterDelegate {
    func addMemoDidAddMemoToTransfer(memo: Memo) {
        addedMemo(memo)
    }
}

extension SendFundsCoordinator: SelectRecipientPresenterDelegate {
    func didSelect(recipient: RecipientDataType) {
        selectedRecipient(recipient)
    }

    func createRecipient() {
        showAddRecipient()
    }

    func selectRecipientDidSelectQR() {
        showScanAddressQR { [weak self] address in
            // Validating address in SendFundsCoordinator.showScanAddressQR.
            self?.qrScanner(didScanAddress: address)
        }
    }
}

extension SendFundsCoordinator: AddRecipientPresenterDelegate {
    func addRecipientDidSelectSave(recipient: RecipientDataType) {
        selectedRecipient(recipient)
    }

    func addRecipientDidSelectQR() {
        showScanAddressQR { [weak self] address in
            // Validating address in SendFundsCoordinator.showScanAddressQR.
            self?.qrScanner(didScanAddress: address)
        }
    }
}

extension SendFundsCoordinator: RequestPasswordDelegate {}

extension SendFundsCoordinator: TransactionSubmittedPresenterDelegate {
    func transactionSubmittedPresenterFinish() {
        parentCoordinator?.sendFundsCoordinatorFinished()
    }
}

extension SendFundsCoordinator: AddRecipientCoordinatorHelper {
    func qrScanner(didScanAddress address: String) {
        let addRecipientViewController = getAddRecipientViewController(dependencyProvider: dependencyProvider)

        navigationController.popToViewController(addRecipientViewController, animated: true)

        addRecipientViewController.presenter.setAccountAddress(address)
    }
}

extension SendFundsCoordinator: CreationFailedPresenterDelegate {
    func finish() {
        parentCoordinator?.sendFundsCoordinatorFinished()
    }
}

extension SendFundsCoordinator: SendFundConfirmationPresenterDelegate {
    func sendFundSubmitted(transfer: TransferDataType, recipient: RecipientDataType) {
        showTransactionSubmitted(transfer: transfer, recipient: recipient)
    }

    func sendFundFailed(error: Error) {
        showTransferFailed(error: error)
    }
}
