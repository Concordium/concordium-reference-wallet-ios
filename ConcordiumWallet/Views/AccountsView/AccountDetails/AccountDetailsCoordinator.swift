//
//  CreateIdentityCoordinator.swift
//  ConcordiumWallet
//
//  Created by Concordium on 14/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import SwiftUI
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
    case earn
}

class AccountDetailsCoordinator: Coordinator,
    RequestPasswordDelegate,
    EarnPresenterDelegate,
    DelegationOnboardingCoordinatorDelegate,
    DelegationStatusPresenterDelegate {
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
        case .earn:
            showEarn(account: account)
        }
    }

    func showAccountDetails(account: AccountDataType) {
        accountDetailsPresenter = AccountDetailsPresenter(dependencyProvider: dependencyProvider,
                                                          account: account,
                                                          delegate: self)
        let vc = AccountDetailsFactory.create(with: accountDetailsPresenter!)
        navigationController.pushViewController(vc, animated: true)
    }

    func showEarn(account: AccountDataType) {
        if account.baker == nil && account.delegation == nil {
            let presenter = EarnPresenter(account: account, delegate: self)
            navigationController.pushViewController(presenter.present(EarnView.self), animated: true)
        } else if account.baker != nil {
            let bakingCoordinator = BakingCoordinator(
                navigationController: BaseNavigationController(),
                dependencyProvider: dependencyProvider,
                account: account,
                parentCoordinator: self)
            bakingCoordinator.start()
            childCoordinators.append(bakingCoordinator)
            navigationController.present(bakingCoordinator.navigationController, animated: true)
            navigationController.popViewController(animated: false)
        } else if account.delegation != nil {
            let coordinator = DelegationCoordinator(navigationController: BaseNavigationController(),
                                                    dependencyProvider: dependencyProvider,
                                                    account: account,
                                                    parentCoordinator: self)
            coordinator.showStatus()
            childCoordinators.append(coordinator)
            navigationController.present(coordinator.navigationController, animated: true, completion: nil)
        }
    }

    func baker() {
        let bakingCoordinator = BakingCoordinator(
            navigationController: BaseNavigationController(),
            dependencyProvider: dependencyProvider,
            account: account,
            parentCoordinator: self)
        bakingCoordinator.start()
        childCoordinators.append(bakingCoordinator)
        navigationController.present(bakingCoordinator.navigationController, animated: true)
        navigationController.popViewController(animated: false)
    }

    func delegation() {
        navigationController.popViewController(animated: false)
        let onboardingDelegator = DelegationOnboardingCoordinator(navigationController: navigationController,
                                                                  parentCoordinator: self,
                                                                  mode: .register)
        childCoordinators.append(onboardingDelegator)
        onboardingDelegator.start()
    }

    func finished(mode: DelegationOnboardingMode) {
        navigationController.popViewController(animated: false)
        let coordinator = DelegationCoordinator(navigationController: BaseNavigationController(),
                                                dependencyProvider: dependencyProvider,
                                                account: account,
                                                parentCoordinator: self)
        coordinator.showPoolSelection(dataHandler: DelegationDataHandler(account: account, isRemoving: false))
        childCoordinators.append(coordinator)
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
    }

    func pressedDismiss() {
        navigationController.dismiss(animated: false)
    }

    func closed() {
        navigationController.popViewController(animated: true)
    }

    func showSendFund(balanceType: AccountBalanceTypeEnum = .balance) {
        let coordinator = SendFundsCoordinator(navigationController: BaseNavigationController(),
                                               delegate: self,
                                               dependencyProvider: dependencyProvider,
                                               account: account,
                                               balanceType: balanceType,
                                               transferType: .simpleTransfer,
                                               tokenType: .ccd
        )
        coordinator.start()
        childCoordinators.append(coordinator)
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
    }
    
    func showSendCIS2Token(balanceType: AccountBalanceTypeEnum = .balance, token: CIS2TokenSelectionRepresentable) {
        let transferType: SendFundTransferType = .simpleTransfer
        let coordinator = SendFundsCoordinator(
            navigationController: BaseNavigationController(),
            delegate: self,
            dependencyProvider: dependencyProvider,
            account: account,
            balanceType: balanceType,
            transferType: .contractUpdate,
            tokenType: SendFundsTokenSelection(from: token)
        )
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
        childCoordinators.append(accountAddressQRCoordinator)
    }

    func showEnableShielding() {
        accountDetailsPresenter = AccountDetailsPresenter(dependencyProvider: dependencyProvider,
                                                          account: account,
                                                          delegate: self)
        let vc = AccountDetailsFactory.create(with: accountDetailsPresenter!)
        navigationController.pushViewController(vc, animated: false)
        showShieldedBalanceOnboarding(showShieldedDelegate: accountDetailsPresenter)
    }

    func showTransactionDetail(viewModel: TransactionViewModel) {
        let vc = TransactionDetailFactory.create(with: TransactionDetailPresenter(delegate: self, viewModel: viewModel))
        navigationController.pushViewController(vc, animated: true)
    }

    func showReleaseSchedule(account: AccountDataType) {
        let vc = ReleaseScheduleDataFactory.create(with: ReleaseSchedulePresenter(delegate: self, account: account))
        navigationController.pushViewController(vc, animated: true)
    }

    func showDelegation() {
        let coordinator = DelegationCoordinator(navigationController: BaseNavigationController(),
                                                dependencyProvider: dependencyProvider,
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

    func pressedStop(cost: GTU, energy: Int) {
    }

    func pressedRegisterOrUpdate() {
    }

    func pressedClose() {
    }

    func showTransferFilters(account: AccountDataType) {
        let vc = TransferFiltersFactory.create(with: TransferFiltersPresenter(delegate: self, account: account))
        navigationController.pushViewController(vc, animated: true)
    }

    func showShieldedBalanceOnboarding(showShieldedDelegate: ShowShieldedDelegate?) {
        let onboardingCarouselViewModel = OnboardingCarouselViewModel(
            title: "onboardingcarousel.shieldedbalance.title".localized,
            pages: [
                OnboardingPage(
                    title: "onboardingcarousel.shieldedbalance.page1.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "shielded_balance_onboarding_en_1")
                ),
                OnboardingPage(
                    title: "onboardingcarousel.shieldedbalance.page2.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "shielded_balance_onboarding_en_2")
                ),
                OnboardingPage(
                    title: "onboardingcarousel.shieldedbalance.page3.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "shielded_balance_onboarding_en_3")
                ),
                OnboardingPage(
                    title: "onboardingcarousel.shieldedbalance.page4.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "shielded_balance_onboarding_en_4")
                ),
                OnboardingPage(
                    title: "onboardingcarousel.shieldedbalance.page5.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "shielded_balance_onboarding_en_5")
                ),
                OnboardingPage(
                    title: "onboardingcarousel.shieldedbalance.page6.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "shielded_balance_onboarding_en_6")
                ),
                OnboardingPage(
                    title: "onboardingcarousel.shieldedbalance.page7.title".localized,
                    viewController: OnboardingCarouselWebContentViewController(htmlFilename: "shielded_balance_onboarding_en_7")
                ),
            ]
        )

        let onboardingCarouselPresenter = OnboardingCarouselPresenter(
            delegate: showShieldedDelegate,
            viewModel: onboardingCarouselViewModel
        )

        let onboardingCarouselViewController = OnboardingCarouselFactory.create(with: onboardingCarouselPresenter)
        onboardingCarouselViewController.hidesBottomBarWhenPushed = true

        navigationController.pushViewController(onboardingCarouselViewController, animated: true)
    }

    func showExportPrivateKey(account: AccountDataType) {
        let presenter = ExportPrivateKeyPresenter(account: account, delegate: self)

        navigationController.pushViewController(presenter.present(ExportPrivateKeyView.self), animated: true)
    }

    func showExportTransactionLog(account: AccountDataType) {
        let presenter = ExportTransactionLogPresenter(account: account, delegate: self)
        navigationController.pushViewController(presenter.present(ExportTransactionLogView.self), animated: true)
    }

    func renameAccount(account: AccountDataType) {
        let alert = UIAlertController(title: "renameaccount.title".localized, message: "renameaccount.message".localized, preferredStyle: .alert)

        alert.addTextField { textField in
            textField.text = account.displayName
        }

        let saveAction = UIAlertAction(title: "renameaccount.save".localized, style: .default, handler: { [weak alert] _ in
            if let textField = alert?.textFields![0], let newName = textField.text, !newName.isEmpty {
                do {
                    try account.write {
                        var mutableAccount = $0
                        mutableAccount.name = newName
                    }.get()
                    if let recipient = self.dependencyProvider.storageManager().getRecipient(withAddress: account.address) {
                        let newRecipient = RecipientEntity(name: newName, address: account.address)
                        try self.dependencyProvider.storageManager().editRecipient(oldRecipient: recipient, newRecipient: newRecipient)
                    }
                    self.navigationController.viewControllers.last(where: { $0 is AccountDetailsViewController })?.title = newName
                } catch {
                    print("\(error.localizedDescription)")
                }
            }
        })

        let cancelAction = UIAlertAction(title: "renameaccount.cancel".localized, style: .cancel, handler: nil)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        navigationController.present(alert, animated: true, completion: nil)
    }
}

extension AccountDetailsCoordinator: AccountDetailsPresenterDelegate {
    func showManageCIS2TokensView() {
        let coordinator = CIS2TokensCoordinator(
            navigationController: BaseNavigationController(),
            dependencyProvider: ServicesProvider.defaultProvider(),
            account: account
        )
        coordinator.start()
        childCoordinators.append(coordinator)
        navigationController.present(coordinator.navigationController, animated: true)
    }

    func tokenSelected(_ token: CIS2TokenSelectionRepresentable) {
        navigationController.pushViewController(
            UIHostingController(
                rootView: TokenDetailsView(
                    token: token,
                    service: dependencyProvider.cis2Service(),
                    popView: { [weak self] in
                        self?.navigationController.popViewController(animated: true)
                    },
                    showAddress: showAccountAddressQR,
                    sendFunds: { [weak self] in self?.showSendCIS2Token(token: token) },
                    context: .database
                )
            ),
            animated: true
        )
    }

    func accountDetailsPresenterSend(_ accountDetailsPresenter: AccountDetailsPresenter, balanceType: AccountBalanceTypeEnum) {
        showSendFund(balanceType: balanceType)
    }

    func accountDetailsPresenterAddress(_ accountDetailsPresenter: AccountDetailsPresenter) {
        showAccountAddressQR()
    }

    func showEarn() {
        showEarn(account: account)
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
        let presenter = AccountSettingsPresenter(account: account, delegate: self)
        navigationController.pushViewController(presenter.present(AccountSettingsView.self), animated: true)
    }

    func transactionSelected(viewModel: TransactionViewModel) {
        showTransactionDetail(viewModel: viewModel)
    }

    func accountDetailsClosed() {
        parentCoordinator?.accountDetailsClosed()
    }
}

extension AccountDetailsCoordinator: ShowShieldedDelegate {
    func onboardingCarouselClosed() {
    }

    func onboardingCarouselSkiped() {
        account = account.withShowShielded(true)
        navigationController.popViewController(animated: false)
        accountDetailsPresenter?.viewDidLoad()
        navigationController.popViewController(animated: true)
    }

    func onboardingCarouselFinished() {
        account = account.withShowShielded(true)
        navigationController.popViewController(animated: false)
        accountDetailsPresenter?.viewDidLoad()
        navigationController.popViewController(animated: true)
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
        childCoordinators.removeAll { $0 is SendFundsCoordinator }
    }
}

extension AccountDetailsCoordinator: AccountAddressQRCoordinatorDelegate {
    func accountAddressQRCoordinatorFinished() {
        navigationController.dismiss(animated: true)
        childCoordinators.removeAll { $0 is AccountAddressQRCoordinator }
    }
}

extension AccountDetailsCoordinator: TransactionDetailPresenterDelegate {
}

extension AccountDetailsCoordinator: AccountSettingsPresenterDelegate {
    func transferFiltersTapped() {
        showTransferFilters(account: account)
    }

    func releaseScheduleTapped() {
        showReleaseSchedule(account: account)
    }

    func showShieldedTapped() {
        showShieldedBalanceOnboarding(showShieldedDelegate: self)
    }

    func hideShieldedTapped() {
        account = account.withShowShielded(false)
        accountDetailsPresenter?.viewDidLoad()
        navigationController.popViewController(animated: true)
    }

    func exportPrivateKeyTapped() {
        showExportPrivateKey(account: account)
    }

    func exportTransactionLogTapped() {
        showExportTransactionLog(account: account)
    }

    func renameAccountTapped() {
        renameAccount(account: account)
    }
}

extension AccountDetailsCoordinator: DelegationCoordinatorDelegate {
    func finished() {
        navigationController.dismiss(animated: true)
        childCoordinators.removeAll { $0 is DelegationCoordinator }
        refreshTransactionList()
    }
}

extension AccountDetailsCoordinator: BakingCoordinatorDelegate {
    func finishedBakingCoordinator() {
        navigationController.dismiss(animated: true)
        childCoordinators.removeAll { $0 is BakingCoordinator }
        refreshTransactionList()
    }
}

extension AccountDetailsCoordinator: ExportPrivateKeyPresenterDelegate {
    func finishedExportingPrivateKey() {
        navigationController.popViewController(animated: true)
    }

    func shareExportedFile(url: URL, completion: @escaping (Bool) -> Void) {
        share(items: [url], from: navigationController, completion: completion)
    }
}

extension AccountDetailsCoordinator: ExportTransactionLogPresenterDelegate {
    func saveTapped(url: URL, completion: @escaping (Bool) -> Void) {
        share(items: [url], from: navigationController, completion: completion)
    }

    func doneTapped() {
        navigationController.popViewController(animated: true)
    }
}
