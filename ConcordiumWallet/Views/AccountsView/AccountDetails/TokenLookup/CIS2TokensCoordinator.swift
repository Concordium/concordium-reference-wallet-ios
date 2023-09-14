//
//  CIS2TokensCoordinator.swift
//  ConcordiumWallet
//

import SwiftUI
import UIKit

class CIS2TokensCoordinator: Coordinator, AccountAddressQRCoordinatorDelegate {

    var childCoordinators: [Coordinator] = []

    var navigationController: UINavigationController
    private var account: AccountDataType
    private var dependencyProvider: CIS2TokensCoordinatorDependencyProvider
    init(
        navigationController: UINavigationController,
        dependencyProvider: CIS2TokensCoordinatorDependencyProvider,
        account: AccountDataType
    ) {
        self.navigationController = navigationController
        self.dependencyProvider = dependencyProvider
        self.account = account
    }

    func start() {
        var view = TokenLookupView(service: dependencyProvider.cis2Service(), account: account)
        view.displayContractTokens = { [weak self] data, contractIndex in
            self?.showTokenSelectionView(with: data, contractIndex: contractIndex)
        }
        navigationController.setViewControllers([UIHostingController(rootView: view)], animated: false)
    }

    private func showTokenDetails(_ token: CIS2TokenSelectionRepresentable) {
        navigationController.pushViewController(
            UIHostingController(
                rootView: TokenDetailsView(
                    token: token,
                    service: dependencyProvider.cis2Service(),
                    popView: { [weak self] in self?.navigationController.popViewController(animated: true) },
                    showAddress: showAccountAddressQR,
                    sendFunds: { [weak self] in self?.showSendFund(for: token) },
                    context: .preview
                )
            ),
            animated: true
        )
    }

    func showAccountAddressQR() {
        let accountAddressQRCoordinator = AccountAddressQRCoordinator(navigationController: BaseNavigationController(),
                                                                      delegate: self,
                                                                      account: account)
        accountAddressQRCoordinator.start()
        navigationController.present(accountAddressQRCoordinator.navigationController, animated: true)
        childCoordinators.append(accountAddressQRCoordinator)
    }
    private func showTokenSelectionView(with model: [CIS2TokenSelectionRepresentable], contractIndex: String) {
        let view = CIS2TokenSelectView(
            viewModel: model,
            accountAdress: account.address,
            contractIndex: contractIndex,
            popView: { [weak self] in self?.navigationController.popViewController(animated: true) },
            didUpdateTokens: { [weak self] in self?.navigationController.dismiss(animated: true) },
            showDetails: showTokenDetails,
            service: dependencyProvider.cis2Service()
        )

        navigationController.pushViewController(UIHostingController(rootView: view), animated: true)
    }

    func accountAddressQRCoordinatorFinished() {
        
    }
    
    func showSendFund(balanceType: AccountBalanceTypeEnum = .balance, for token: CIS2TokenSelectionRepresentable) {
        let transferType: SendFundTransferType = balanceType == .shielded ? .encryptedTransfer : .simpleTransfer
        let coordinator = SendFundsCoordinator(navigationController: BaseNavigationController(),
                                               delegate: self,
                                               dependencyProvider: dependencyProvider,
                                               account: account,
                                               balanceType: balanceType,
                                               transferType: transferType, tokenType: .ccd)
        coordinator.start()
        childCoordinators.append(coordinator)
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
    }
}

extension CIS2TokensCoordinator: SendFundsCoordinatorDelegate {
    func sendFundsCoordinatorFinished() {
        
    }
}
