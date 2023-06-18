//
//  AccountsCoordinator.swift
//  ConcordiumWallet
//
//  Created by Concordium on 05/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Combine
import Foundation
import SwiftUI
import UIKit
import WalletConnectNetworking
import Web3Wallet

protocol AccountsCoordinatorDelegate: AnyObject {
    func createNewIdentity()
    func createNewAccount()
    func noIdentitiesFound()
    func showIdentities()
}

class AccountsCoordinator: Coordinator {
    typealias DependencyProvider = AccountsFlowCoordinatorDependencyProvider &
        StakeCoordinatorDependencyProvider &
        IdentitiesFlowCoordinatorDependencyProvider

    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    weak var delegate: AccountsCoordinatorDelegate?
    weak var accountsPresenterDelegate: AccountsPresenterDelegate?
    private weak var appSettingsDelegate: AppSettingsDelegate?
    private var dependencyProvider: DependencyProvider

    init(
        navigationController: UINavigationController,
        dependencyProvider: DependencyProvider,
        appSettingsDelegate: AppSettingsDelegate?,
        accountsPresenterDelegate: AccountsPresenterDelegate
    ) {
        self.navigationController = navigationController
        self.dependencyProvider = dependencyProvider
        self.appSettingsDelegate = appSettingsDelegate
        self.accountsPresenterDelegate = accountsPresenterDelegate

    }

    func start() {
        let accountsPresenter = AccountsPresenter(
            dependencyProvider: dependencyProvider,
            delegate: accountsPresenterDelegate!,
            appSettingsDelegate: appSettingsDelegate,
            walletConnectDelegate: self
        )
        let accountsViewController = AccountsFactory.create(with: accountsPresenter)
        navigationController.viewControllers = [accountsViewController]
    }

    func showCreateNewAccount(withDefaultValuesFrom account: AccountDataType? = nil) {
        if FeatureFlag.enabledFlags.contains(.recoveryCode) {
            let seedIdentitiesCoordinator = SeedIdentitiesCoordinator(
                navigationController: BaseNavigationController(),
                action: .createAccount,
                dependencyProvider: dependencyProvider,
                delegate: self
            )

            childCoordinators.append(seedIdentitiesCoordinator)
            seedIdentitiesCoordinator.start()
            navigationController.present(seedIdentitiesCoordinator.navigationController, animated: true)
        } else {
            let createAccountCoordinator = CreateAccountCoordinator(navigationController: BaseNavigationController(),
                                                                    dependencyProvider: dependencyProvider, parentCoordinator: self)
            childCoordinators.append(createAccountCoordinator)
            createAccountCoordinator.start(withDefaultValuesFrom: account)
            navigationController.present(createAccountCoordinator.navigationController, animated: true, completion: nil)
        }
    }

    func showCreateNewIdentity() {
        let seedIdentitiesCoordinator = SeedIdentitiesCoordinator(
            navigationController: BaseNavigationController(),
            action: .createIdentity,
            dependencyProvider: dependencyProvider,
            delegate: self
        )

        childCoordinators.append(seedIdentitiesCoordinator)
        seedIdentitiesCoordinator.start()
        navigationController.present(seedIdentitiesCoordinator.navigationController, animated: true)
    }

    func show(account: AccountDataType, entryPoint: AccountDetailsFlowEntryPoint) {
        let accountDetailsCoordinator = AccountDetailsCoordinator(navigationController: navigationController,
                                                                  dependencyProvider: dependencyProvider,
                                                                  parentCoordinator: self,
                                                                  account: account)
        childCoordinators.append(accountDetailsCoordinator)
        accountDetailsCoordinator.start(entryPoint: entryPoint)
    }

    func showExport() {
        let vc = ExportFactory.create(with: ExportPresenter(
            dependencyProvider: ServicesProvider.defaultProvider(),
            requestPasswordDelegate: self,
            delegate: self
        ))
        navigationController.pushViewController(vc, animated: true)
    }

    private func showCreateExportPassword() -> AnyPublisher<String, Error> {
        let selectExportPasswordCoordinator = CreateExportPasswordCoordinator(
            navigationController: TransparentNavigationController(),
            dependencyProvider: ServicesProvider.defaultProvider()
        )
        childCoordinators.append(selectExportPasswordCoordinator)
        selectExportPasswordCoordinator.navigationController.modalPresentationStyle = .fullScreen
        selectExportPasswordCoordinator.start()
        navigationController.present(selectExportPasswordCoordinator.navigationController, animated: true)
        return selectExportPasswordCoordinator.passwordPublisher.eraseToAnyPublisher()
    }
}

extension AccountsCoordinator: AccountsPresenterDelegate {
    func showSettings() {
    }

    func didSelectMakeBackup() {
        showExport()
    }

    func didSelectPendingIdentity(identity: IdentityDataType) {
        delegate?.showIdentities()
    }

    func createNewAccount() {
        delegate?.createNewAccount()
    }

    func createNewIdentity() {
        delegate?.createNewIdentity()
    }

    func userPerformed(action: AccountCardAction, on account: AccountDataType) {
        let entryPoint: AccountDetailsFlowEntryPoint!
        switch action {
        case .tap, .more:
            entryPoint = .details
        case .send:
            entryPoint = .send
        case .earn:
            entryPoint = .earn
        case .receive:
            entryPoint = .receive
        }
        show(account: account, entryPoint: entryPoint)
    }

    func enableShielded(on account: AccountDataType) {
        let entryPoint = AccountDetailsFlowEntryPoint.enableShielded
        show(account: account, entryPoint: entryPoint)
    }

    func noValidIdentitiesAvailable() {
        delegate?.noIdentitiesFound()
    }

    func tryAgainIdentity() {
        delegate?.createNewIdentity()
    }
}

extension AccountsCoordinator: CreateNewAccountDelegate {
    func createNewAccountFinished() {
        navigationController.dismiss(animated: true)
        childCoordinators.removeAll(where: { $0 is CreateAccountCoordinator })
    }

    func createNewAccountCancelled() {
        navigationController.dismiss(animated: true)
        childCoordinators.removeAll(where: { $0 is CreateAccountCoordinator })
    }
}

extension AccountsCoordinator: AccountDetailsDelegate {
    func accountDetailsClosed() {
        navigationController.dismiss(animated: true, completion: nil)
        if let lastOccurenceIndex = childCoordinators.lastIndex(where: { $0 is AccountDetailsCoordinator }) {
            childCoordinators.remove(at: lastOccurenceIndex)
        }
    }

    func retryCreateAccount(failedAccount: AccountDataType) {
        navigationController.popViewController(animated: true)
        showCreateNewAccount(withDefaultValuesFrom: failedAccount)
    }

    func accountRemoved() {
        navigationController.popViewController(animated: true)
    }
}

extension AccountsCoordinator: RequestPasswordDelegate { }

extension AccountsCoordinator: ExportPresenterDelegate {
    func createExportPassword() -> AnyPublisher<String, Error> {
        let cleanup: (Result<String, Error>) -> Future<String, Error> = { [weak self] result in
            let future = Future<String, Error> { promise in
                self?.navigationController.dismiss(animated: true) {
                    promise(result)
                }
                self?.childCoordinators.removeAll { coordinator in
                    coordinator is CreateExportPasswordCoordinator
                }
            }
            return future
        }
        return showCreateExportPassword()
            .flatMap { cleanup(.success($0)) }
            .catch { cleanup(.failure($0)) }
            .eraseToAnyPublisher()
    }

    func shareExportedFile(url: URL, completion: @escaping () -> Void) {
        share(items: [url], from: navigationController) { completed in
            if completed {
                AppSettings.needsBackupWarning = false
            }

            completion()
            self.exportFinished()
        }
    }

    func exportFinished() {
        navigationController.popViewController(animated: true)
    }
}

extension AccountsCoordinator: SeedIdentitiesCoordinatorDelegate {
    func seedIdentityCoordinatorWasFinished(for identity: IdentityDataType) {
        navigationController.dismiss(animated: true)
        childCoordinators.removeAll(where: { $0 is SeedIdentitiesCoordinator })

        NotificationCenter.default.post(name: Notification.Name("seedAccountCoordinatorWasFinishedNotification"), object: nil)
    }
}

protocol WalletConnectDelegate: AnyObject {
    func showWalletConnectScanner()
}

extension AccountsCoordinator: WalletConnectDelegate {
    func showWalletConnectScanner() {
        // For now we just print the following events.
//        Sign.instance.sessionDeletePublisher
//            .receive(on: DispatchQueue.main)
//            .sink { sessionId, reason in
//                // Called when the dApp disconnects - not when we do ourselves!
//                print("DEBUG: Session \(sessionId) deleted with reason \(reason)")
//
//                // Connection lost or disconnected: Pop "connected" screen.
//                // TODO: Only do this if we're actually on that screen (i.e. the deleted session matches the currently connected one).
//                self.navigationController.setNavigationBarHidden(false, animated: false)
//                self.navigationController.popToRootViewController(animated: true)
//            }
//            .store(in: &cancellables)
//
//        Sign.instance.sessionEventPublisher
//            .receive(on: DispatchQueue.main)
//            .sink { event in
//                print("DEBUG: Session event: \(event)")
//            }
//            .store(in: &cancellables)
//        Sign.instance.sessionExtendPublisher
//            .receive(on: DispatchQueue.main)
//            .sink { sessionTopic, date in
//                print("DEBUG: Session \(sessionTopic) extended until \(date)")
//            }
//            .store(in: &cancellables)
//
//        Sign.instance.sessionUpdatePublisher
//            .receive(on: DispatchQueue.main)
//            .sink { sessionTopic, _ in
//                print("DEBUG: Session \(sessionTopic) updated")
//            }
//            .store(in: &cancellables)
//        Sign.instance.socketConnectionStatusPublisher
//            .receive(on: DispatchQueue.main)
//            .sink { status in
//                print("DEBUG: Socket connection status update: \(status)")
//            }
//            .store(in: &cancellables)
//        Sign.instance.sessionResponsePublisher
//            .receive(on: DispatchQueue.main)
//            .sink { response in
//                print("DEBUG: Response: \(response)")
//            }
//            .store(in: &cancellables)
//        Sign.instance.sessionRejectionPublisher
//            .receive(on: DispatchQueue.main)
//            .sink { proposal, reason in
//                print("DEBUG: Proposal \(proposal) rejected with reason \(reason)")
//            }
//            .store(in: &cancellables)
//
//        Sign.instance.pingResponsePublisher
//            .receive(on: DispatchQueue.main)
//            .sink { ping in
//                print("DEBUG: Ping: \(ping)")
//            }
//            .store(in: &cancellables)
//
//        setupWalletConnectRequestBinding()
//
////        // Temporarily use hardcoded connection string rather than scanning QR code.
////        // Unsure why, but if we clear pairings and instantiate this one, it seems to connect without the proposal thing...
////        let wc = "wc:39e17f8223d80748d56e528c6715f211afd3b4e0dee4ac887a79d644308d157a@2?relay-protocol=irn&symKey=c370924b1dd87b047fc8726f33d80adecc41f350635979bfbe597c58fcf5f2bd"
////        do {
////            try Pair.instance.cleanup()
////        } catch let error {
////            print("ERROR: cannot clean up pairings: \(error)")
////        }

        let coordinator = WalletConnectCoordinator(navigationController: navigationController,
                                                   dependencyProvider: dependencyProvider,
                                                   parentCoodinator: self
        )
        coordinator.start()
    }
}
