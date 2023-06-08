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
import WalletConnectPairing
import WalletConnectSign

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
    private var cancellables: [AnyCancellable] = []
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
        let metadata = AppMetadata(
            name: "Concordium",
            description: "Concordium - Blockchain Wallet",
            url: "wallet.connect",
            icons: [],
            verifyUrl: "verify.walletconnect.com"
        )
        Pair.configure(metadata: metadata)
        Networking.configure(projectId: "76324905a70fe5c388bab46d3e0564dc", socketFactory: SocketFactory())

        // Handler for session proposals, i.e. requests for connections to be established.
        Sign.instance.sessionProposalPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { failure in
                print(failure) // TODO: should we handle error?
            }, receiveValue: { [weak self] proposal, _ in
                guard let self = self else { return }
                
                // TODO Auto-reject proposal if namespaces include non-supported chain/method/event.
                
                let viewModel = WalletConnectAccountSelectViewModel(
                    storageManager: self.dependencyProvider.storageManager(), proposal: proposal
                )

                viewModel.didSelectAccount = { accountAddress in
                    self.navigationController.pushViewController(
                        UIHostingController(
                            rootView: WalletConnectApprovalView(
                                title: "walletconnect.connect.approve.title".localized,
                                subtitle: "walletconnect.connect.approve.subtitle".localizedNonempty,
                                contentView: WalletConnectProposalApprovalView(
                                    accountName: accountAddress,
                                    proposal: proposal.proposalData
                                ),
                                viewModel: .init(
                                    didAccept: {
                                        Task {
                                            do {
                                                try await Sign.instance.approve(
                                                    proposalId: proposal.id,
                                                    namespaces: [ // TODO un-hardcode
                                                        "ccd": SessionNamespace(
                                                            chains: [Blockchain("ccd:testnet")!],
                                                            accounts: [Account("ccd:testnet:\(accountAddress)")!],
                                                            methods: ["sign_and_send_transaction", "sign_message"],
                                                            events: ["chain_changed", "accounts_changed"]
                                                        )
                                                ])
                                            } catch {
                                                print("ERROR: approval of connection failed: \(error)")
                                            }
                                        }
                                        
                                        // TODO In "sessionSettlePublisher" event listener below, push "connected" screen that just allows user to disconnect.
                                        //      Handle request events in 'sessionRequestPublisher' listener.
                                    },
                                    didDecline: {
                                        // User declined the request to connect. Reject it and don't await completion before popping the VC.
                                        Task {
                                            do {
                                                try await Sign.instance.reject(proposalId: proposal.id, reason: .userRejected)
                                            } catch let error {
                                                print("ERROR: rejection of connection failed: \(error)")
                                            }
                                        }
                                        
                                        // TODO Should do in response to "reject" event?
                                        self.navigationController.popToRootViewController(animated: true)
                                    }
                                )
                            )
                        ),
                        animated: true
                    )
                }

                let viewController = WalletConnectAccountSelectViewController(viewModel: viewModel)
                self.navigationController.pushViewController(viewController, animated: true)

            })
            .store(in: &cancellables)
        
        // For now we just print the following events.
        Sign.instance.sessionDeletePublisher
            .receive(on: DispatchQueue.main)
            .sink { (sessionId, reason) in
                print("DEBUG: Session \(sessionId) deleted with reason \(reason)")
            }
            .store(in: &cancellables)
        Sign.instance.sessionEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { event in
                print("DEBUG: Session event: \(event)")
            }
            .store(in: &cancellables)
        Sign.instance.sessionExtendPublisher
            .sink { (sessionTopic, date) in
                print("DEBUG: Session \(sessionTopic) extended until \(date)")
            }
            .store(in: &cancellables)
        Sign.instance.sessionSettlePublisher
            .sink { session in
                // TODO Open "disconnect" screen.
                print("DEBUG: Session \(session) settled")
            }
            .store(in: &cancellables)
        Sign.instance.sessionUpdatePublisher
            .sink { (sessionTopic, namespaces) in
                print("DEBUG: Session \(sessionTopic) updated")
            }
            .store(in: &cancellables)
        Sign.instance.socketConnectionStatusPublisher
            .sink { status in
                print("DEBUG: Socket connection status update: \(status)")
            }
            .store(in: &cancellables)
        Sign.instance.sessionResponsePublisher
            .sink { response in
                print("DEBUG: Response: \(response)")
            }
            .store(in: &cancellables)
        Sign.instance.sessionRejectionPublisher
            .sink { (proposal, reason) in
                print("DEBUG: Proposal \(proposal) rejected with reason \(reason)")
            }
            .store(in: &cancellables)
        
    Sign.instance.pingResponsePublisher
        .sink { ping in
            print("DEBUG: Ping: \(ping)")
        }
        .store(in: &cancellables)

        // Handler for incoming requests on established connection.
        Sign.instance.sessionRequestPublisher
            .receive(on: DispatchQueue.main)
            .sink { request, _ in
                print("DEBUG: Incoming request: \(request)") // TODO handle...
            }
            .store(in: &cancellables)

        // Temporarily use hardcoded connection string rather than scanning QR code.
        // Unsure why, but if we clear pairings and instantiate this one, it seems to connect without the proposal thing...
        let wc = "wc:39e17f8223d80748d56e528c6715f211afd3b4e0dee4ac887a79d644308d157a@2?relay-protocol=irn&symKey=c370924b1dd87b047fc8726f33d80adecc41f350635979bfbe597c58fcf5f2bd"
        do {
            try Pair.instance.cleanup()
        } catch let error {
            print("ERROR: cannot clean up pairings: \(error)")
        }
        
        Task {
            do {
                try await Pair.instance.pair(uri: WalletConnectURI(string: wc)!)
            } catch let error {
                print("ERROR: cannot pair: \(error)")
            }
        }

//        let vc = ScanQRViewControllerFactory.create(
//            with: ScanQRPresenter(
//                didScanQrCode: { [weak self] value in
//                    // TODO Can do more detailed check?
//                    if !value.lowercased().hasPrefix("wc:") {
//                        return false
//                    }
//
//                    // Successfully scanner WalletConnect QR.
//                    // TODO: Handle Wallet Connect logic here
//                    self?.navigationController.popViewController(animated: true)
//                    return true
//                }
//            )
//        )
//        navigationController.pushViewController(vc, animated: true)
    }
}
