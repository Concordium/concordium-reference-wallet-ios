//
//  CreateIdentityCoordinator.swift
//  ConcordiumWallet
//
//  Created by Dennis Vexborg Kristensen on 14/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

protocol AccountDetailsDelegate: class {
    func accountDetailsClosed()
    func retryCreateAccount(failedAccount: AccountDataType)
    func accountRemoved()
}

class AccountDetailsCoordinator: Coordinator, RequestPasswordDelegate {
    var childCoordinators = [Coordinator]()
    weak var parentCoordinator: AccountDetailsDelegate?

    var navigationController: UINavigationController

    private var dependencyProvider: AccountsFlowCoordinatorDependencyProvider
    private var account: AccountDataType
    private var balanceType: AccountBalanceTypeEnum
    private var accountDetailsPresenter: AccountDetailsPresenter?
    
    init(navigationController: UINavigationController,
         dependencyProvider: AccountsFlowCoordinatorDependencyProvider,
         parentCoordinator: AccountDetailsDelegate,
         account: AccountDataType,
         balanceType: AccountBalanceTypeEnum) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.dependencyProvider = dependencyProvider
        self.account = account
        self.navigationController.modalPresentationStyle = .fullScreen
        self.balanceType = balanceType
    }

//    deinit {
//        print("deinit")
//    }
    
    func start() {
        showAccountDetails(account: account)
    }
    
    func showAccountDetails(account: AccountDataType) {
        accountDetailsPresenter = AccountDetailsPresenter(dependencyProvider: dependencyProvider, account: account, balanceType: balanceType, delegate: self)
        let vc = AccountDetailsFactory.create(with: accountDetailsPresenter!)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showSendFund() {
        let transferType: TransferType = balanceType == .shielded ? .encryptedTransfer : .simpleTransfer
        let coordinator = SendFundsCoordinator(navigationController: BaseNavigationController(),
                                               delegate: self,
                                               dependencyProvider: self.dependencyProvider,
                                               account: account,
                                               balanceType: balanceType,
                                               transferType: transferType)
        coordinator.start()
        childCoordinators.append(coordinator)
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
    }

    func shieldUnshieldFund() {
        let transferType: TransferType = balanceType == .shielded ? .transferToPublic : .transferToSecret
        let coordinator = SendFundsCoordinator(navigationController: BaseNavigationController(),
                                               delegate: self,
                                               dependencyProvider: self.dependencyProvider,
                                               account: account,
                                               balanceType: balanceType,
                                               transferType: transferType)
        coordinator.start()
        childCoordinators.append(coordinator)
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
    }
    
    func showAccountAddressQR() {
        let accountAddressQRCoordinator = AccountAddressQRCoordinator(navigationController: BaseNavigationController(),
                                                                      delegate: self,
                                                                      account: account)
        accountAddressQRCoordinator.start()
        navigationController.present(accountAddressQRCoordinator.navigationController, animated: true)
        self.childCoordinators.append(accountAddressQRCoordinator)
    }
    
    func showTransactionDetail(viewModel: TransactionViewModel) {
        let vc = TransactionDetailFactory.create(with: TransactionDetailPresenter(delegate: self, viewModel: viewModel))
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showBurgerMenuOverlay(account: AccountDataType, burgerMenuDismissDelegate: BurgerMenuDismissDelegate) {
        let vc = BurgerMenuFactory.create(with: BurgerMenuPresenter(delegate: self, account: account, dismissDelegate: burgerMenuDismissDelegate))
        vc.modalPresentationStyle = .overFullScreen
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        keyWindow?.rootViewController?.present(vc, animated: false, completion: nil)
    }
    
    func showReleaseSchedule(account: AccountDataType) {
        let vc = ReleaseScheduleDataFactory.create(with: ReleaseSchedulePresenter(delegate: self, account: account))
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showTransferFilters(account: AccountDataType) {
        let vc = TransferFiltersFactory.create(with: TransferFiltersPresenter(delegate: self, account: account))
        navigationController.pushViewController(vc, animated: true)
    }
}

extension AccountDetailsCoordinator: AccountDetailsPresenterDelegate {
    func accountDetailsPresenterSend(_ accountDetailsPresenter: AccountDetailsPresenter) {
        showSendFund()
    }
    
    func accountDetailsPresenterShieldUnshield(_ accountDetailsPresenter: AccountDetailsPresenter) {
        shieldUnshieldFund()
    }
    
    func accountDetailsPresenterAddress(_ accountDetailsPresenter: AccountDetailsPresenter) {
        showAccountAddressQR()
    }
    
    func accountDetailsPresenter(_ accountDetailsPresenter: AccountDetailsPresenter, retryFailedAccount account: AccountDataType) {
        var accountCopy = AccountDataTypeFactory.create()
        accountCopy.name = account.name
        dependencyProvider.storageManager().removeAccount(account: account)
        parentCoordinator?.retryCreateAccount(failedAccount: accountCopy)
    }

    func accountDetailsPresenter(_ accountDetailsPresenter: AccountDetailsPresenter, removeFailedAccount account: AccountDataType) {
        dependencyProvider.storageManager().removeAccount(account: account)
        parentCoordinator?.accountRemoved()
    }
    
    func accountDetailsShowBurgerMenu(_ accountDetailsPresenter: AccountDetailsPresenter) {
//        self.parentCoordinator?.accountDetailsClosed()
        self.showBurgerMenuOverlay(account: accountDetailsPresenter.account, burgerMenuDismissDelegate: accountDetailsPresenter)
//        self.showReleaseSchedule(account: accountDetailsPresenter.account)
    }
    
    func transactionSelected(viewModel: TransactionViewModel) {
        showTransactionDetail(viewModel: viewModel)
    }
    
    func accountDetailsClosed() {
        self.parentCoordinator?.accountDetailsClosed()
    }
}

extension AccountDetailsCoordinator: ReleaseSchedulePresenterDelegate {
    
}

extension AccountDetailsCoordinator: TransferFiltersPresenterDelegate {
    func refreshTransactionList() {
        accountDetailsPresenter?.setShouldRefresh(true)
    }
}

extension AccountDetailsCoordinator: SendFundsCoordinatorDelegate {
    func sendFundsCoordinatorFinished() {
        navigationController.dismiss(animated: true, completion: nil)
        self.childCoordinators.removeAll {$0 is SendFundsCoordinator}
    }
}

extension AccountDetailsCoordinator: AccountAddressQRCoordinatorDelegate {
    func accountAddressQRCoordinatorFinished() {
        navigationController.dismiss(animated: true)
        self.childCoordinators.removeAll {$0 is AccountAddressQRCoordinator}
    }
}

extension AccountDetailsCoordinator: TransactionDetailPresenterDelegate {
    
}

extension AccountDetailsCoordinator: BurgerMenuPresenterDelegate {
    func pressedOption(action: BurgerMenuAction, account: AccountDataType) {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        switch action {
        case .releaseSchedule:
            keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
            showReleaseSchedule(account: account)
        case .transferFilters:
            keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
            showTransferFilters(account: account)
        case .dismiss:
            keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
        }
    }
}
