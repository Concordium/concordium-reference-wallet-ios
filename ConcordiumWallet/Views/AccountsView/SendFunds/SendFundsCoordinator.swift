//
// Created by Concordium on 16/04/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import UIKit

protocol SendFundsCoordinatorDelegate: AnyObject {
    func sendFundsCoordinatorFinished()
}

class SendFundsCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    weak var parentCoordinator: SendFundsCoordinatorDelegate?

    var navigationController: UINavigationController
    private var account: AccountDataType
    private var balanceType: AccountBalanceTypeEnum
    private var transferType: TransferType
    private var dependencyProvider: AccountsFlowCoordinatorDependencyProvider
    var sendFundPresenter: SendFundPresenter?

    init(navigationController: UINavigationController,
         delegate: SendFundsCoordinatorDelegate,
         dependencyProvider: AccountsFlowCoordinatorDependencyProvider,
         account: AccountDataType,
         balanceType: AccountBalanceTypeEnum,
         transferType: TransferType) {
        self.account = account
        self.balanceType = balanceType
        self.transferType = transferType
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .fullScreen
        self.parentCoordinator = delegate
        self.dependencyProvider = dependencyProvider
    }

    func start() {
        let sendFundPresenter = SendFundPresenter(account: account,
                                                  balanceType: balanceType,
                                                  transferType: transferType,
                                                  dependencyProvider: dependencyProvider,
                                                  delegate: self)
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

    func showScanAddressQR() {
        let vc = ScanAddressQRFactory.create(with: ScanAddressQRPresenter(wallet: dependencyProvider.mobileWallet(), delegate: self))
        navigationController.pushViewController(vc, animated: true)
    }

    func showSendFundConfirmation(
        amount: GTU,
        energy: Int,
        from account: AccountDataType,
        to recipient: RecipientDataType,
        memo: String?,
        cost: GTU,
        transferType: TransferType
    ) {
        let presenter = SendFundConfirmationPresenter(
            delegate: self, amount: amount,
            from: account, to: recipient,
            memo: memo,
            cost: cost,
            energy: energy,
            dependencyProvider: dependencyProvider,
            transferType: transferType
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
    func sendFundPresenter(
        didSelectTransferAmount amount: GTU,
        energyUsed energy: Int,
        from account: AccountDataType,
        to recipient: RecipientDataType,
        memo: String?,
        cost: GTU,
        transferType: TransferType
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
        self.parentCoordinator?.sendFundsCoordinatorFinished()
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
        showScanAddressQR()
    }
}

extension SendFundsCoordinator: AddRecipientPresenterDelegate {
    func addRecipientDidSelectSave(recipient: RecipientDataType) {
        selectedRecipient(recipient)
    }

    func addRecipientDidSelectQR() {
        showScanAddressQR()
    }
}

extension SendFundsCoordinator: RequestPasswordDelegate {}

extension SendFundsCoordinator: TransactionSubmittedPresenterDelegate {
    func transactionSubmittedPresenterFinish() {
        parentCoordinator?.sendFundsCoordinatorFinished()
    }
}

extension SendFundsCoordinator: ScanAddressQRPresenterDelegate, AddRecipientCoordinatorHelper {
    func scanAddressQr(didScanAddress address: String) {
        let addRecipientViewController = getAddRecipientViewController(dependencyProvider: dependencyProvider)

        self.navigationController.popToViewController(addRecipientViewController, animated: true)

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
