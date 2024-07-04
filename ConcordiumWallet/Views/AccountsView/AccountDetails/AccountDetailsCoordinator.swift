//
//  CreateIdentityCoordinator.swift
//  ConcordiumWallet
//
//  Created by Concordium on 14/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

protocol AccountDetailsDelegate: AnyObject {
    func accountDetailsClosed()
    func retryCreateAccount(failedAccount: AccountDataType)
    func accountRemoved()
}

enum AccountDetailsFlowEntryPoint {
    case details
    case send
    case receive
    case enableShielded
}

class AccountDetailsCoordinator: Coordinator, RequestPasswordDelegate {
    var childCoordinators = [Coordinator]()
    weak var parentCoordinator: AccountDetailsDelegate?

    var navigationController: UINavigationController

    private var dependencyProvider: AccountsFlowCoordinatorDependencyProvider & StakeCoordinatorDependencyProvider
    private var account: AccountDataType

    private var accountDetailsPresenter: AccountDetailsPresenter?
    
    init(navigationController: UINavigationController,
         dependencyProvider: AccountsFlowCoordinatorDependencyProvider & StakeCoordinatorDependencyProvider,
         parentCoordinator: AccountDetailsDelegate,
         account: AccountDataType) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.dependencyProvider = dependencyProvider
        self.account = account
        self.navigationController.modalPresentationStyle = .fullScreen

    }
    
    func start() {
        start(entryPoint: .details)
    }
    
    func start(entryPoint: AccountDetailsFlowEntryPoint) {
        switch entryPoint {
        case .details:
            showAccountDetails(account: account)
        case .send:
            showSendFund()
        case .receive:
            showAccountAddressQR()
        case .enableShielded:
            showEnableShielding()
        }
    }
    
    func showAccountDetails(account: AccountDataType) {
        accountDetailsPresenter = AccountDetailsPresenter(dependencyProvider: dependencyProvider,
                                                          account: account,
                                                          delegate: self)
        let vc = AccountDetailsFactory.create(with: accountDetailsPresenter!)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showSendFund(balanceType: AccountBalanceTypeEnum = .balance) {
        let coordinator = SendFundsCoordinator(navigationController: BaseNavigationController(),
                                               delegate: self,
                                               dependencyProvider: self.dependencyProvider,
                                               account: account,
                                               balanceType: balanceType,
                                               transferType: .simpleTransfer)
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
    
    func showEnableShielding() {
        accountDetailsPresenter = AccountDetailsPresenter(dependencyProvider: dependencyProvider,
                                                          account: account,
                                                          delegate: self)
        let vc = AccountDetailsFactory.create(with: accountDetailsPresenter!)
        navigationController.pushViewController(vc, animated: false)
    }
    
    func showTransactionDetail(viewModel: TransactionViewModel) {
        let vc = TransactionDetailFactory.create(with: TransactionDetailPresenter(delegate: self, viewModel: viewModel))
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showBurgerMenuOverlay(account: AccountDataType,
                               balanceType: AccountBalanceTypeEnum,
                               showsDecrypt: Bool,
                               burgerMenuDismissDelegate: BurgerMenuAccountDetailsDismissDelegate,
                               showShieldedDelegate: ShowShieldedDelegate) {
        let presenter = BurgerMenuAccountDetailsPresenter(
            delegate: self,
            account: account,
            balance: balanceType,
            showsDecrypt: showsDecrypt,
            dismissDelegate: burgerMenuDismissDelegate,
            showShieldedDelegate: showShieldedDelegate,
            dependencyProvider: dependencyProvider
        )
        
        let vc = BurgerMenuFactory.create(with: presenter)
        vc.modalPresentationStyle = .overFullScreen
        presenter.view = vc
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
    
    func showDelegation() {
        let coordinator = DelegationCoordinator(navigationController: BaseNavigationController(),
                                                          dependencyProvider: dependencyProvider ,
                                                          account: account,
                                                          parentCoordinator: self)
        coordinator.start()
        childCoordinators.append(coordinator)
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
    }
    
    func showBaking() {
        let coordinator = BakingCoordinator(
            navigationController: BaseNavigationController(),
            dependencyProvider: dependencyProvider,
            account: account,
            parentCoordinator: self)
        
        coordinator.start()
        childCoordinators.append(coordinator)
        navigationController.present(coordinator.navigationController, animated: true)
    }

    func showTransferFilters(account: AccountDataType) {
        let vc = TransferFiltersFactory.create(with: TransferFiltersPresenter(delegate: self, account: account))
        navigationController.pushViewController(vc, animated: true)
    }
}

extension AccountDetailsCoordinator: AccountDetailsPresenterDelegate {
    func accountDetailsPresenterSend(_ accountDetailsPresenter: AccountDetailsPresenter, balanceType: AccountBalanceTypeEnum) {
        showSendFund(balanceType: balanceType)
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
    
    func accountDetailsShowBurgerMenu(_ accountDetailsPresenter: AccountDetailsPresenter,
                                      balanceType: AccountBalanceTypeEnum,
                                      showsDecrypt: Bool) {
        self.showBurgerMenuOverlay(account: accountDetailsPresenter.account,
                                   balanceType: balanceType,
                                   showsDecrypt: showsDecrypt,
                                   burgerMenuDismissDelegate: accountDetailsPresenter,
                                   showShieldedDelegate: accountDetailsPresenter)
    }
    
    func transactionSelected(viewModel: TransactionViewModel) {
        showTransactionDetail(viewModel: viewModel)
    }
    
    func accountDetailsClosed() {
        self.parentCoordinator?.accountDetailsClosed()
    }
}

extension AccountDetailsCoordinator: OnboardingCarouselPresenterDelegate {
    func onboardingCarouselClosed() {}
    func onboardingCarouselSkiped() {}
    func onboardingCarouselFinished() {}
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

extension AccountDetailsCoordinator: BurgerMenuAccountDetailsPresenterDelegate {
    typealias Action = BurgerMenuAccountDetailsAction
    func pressedOption(action: BurgerMenuAccountDetailsAction, account: AccountDataType) {
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
        case .shieldedBalance(_, let shouldShow, let showShieldedDelegate):
            keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
            showShieldedDelegate?.onboardingCarouselFinished()
        case .delegation:
            keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
            showDelegation()
        case .baking:
            keyWindow?.rootViewController?.dismiss(animated: false)
            showBaking()
        case .decrypt, .dismiss:
            keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
        }
    }
}

extension AccountDetailsCoordinator: DelegationCoordinatorDelegate {
    func finished() {
        navigationController.dismiss(animated: true)
        self.childCoordinators.removeAll {$0 is DelegationCoordinator }
        refreshTransactionList()
    }
}

extension AccountDetailsCoordinator: BakingCoordinatorDelegate {
    func finishedBakingCoordinator() {
        navigationController.dismiss(animated: true)
        self.childCoordinators.removeAll { $0 is BakingCoordinator }
        refreshTransactionList()
    }
}
