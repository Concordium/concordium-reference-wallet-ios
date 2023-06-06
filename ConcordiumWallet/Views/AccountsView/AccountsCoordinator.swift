//
//  AccountsCoordinator.swift
//  ConcordiumWallet
//
//  Created by Concordium on 05/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Combine
import Foundation
import UIKit
import WalletConnectSign
import WalletConnectNetworking

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
        self.childCoordinators.append(selectExportPasswordCoordinator)
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
        self.delegate?.noIdentitiesFound()
    }
    
    func tryAgainIdentity() {
        self.delegate?.createNewIdentity()
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

        try! Pair.instance.cleanup()

        Sign.instance.sessionProposalPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { failure in
            print(failure)
            }, receiveValue: { [weak self] value in
                guard let self = self else { return }
                    let viewModel = WalletConnectAccountSelectViewModel(storageManager: self.dependencyProvider.storageManager(), proposal: value.proposal)
                let viewController = WalletConnectAccountSelectViewController(viewModel: viewModel)
                    self.navigationController.pushViewController(viewController, animated: true)
                
        })
        .store(in: &cancellables)

        
        Sign.instance.sessionRequestPublisher
            .receive(on: DispatchQueue.main)
            .sink { (request, _) in
                // TODO: Display approve screen once it's done.
                print(request)
            }
            .store(in: &cancellables)
        
        Task {
            do {
                try await Pair.instance.pair(uri: WalletConnectURI(string: "wc:556792d9ecea2eb698449e265d7850e0cb2f0d24124a37a0ede2f0c115995e28@2?relay-protocol=irn&symKey=77b2298f8dbdf4adf4694bd33a284248d0439dcfc239ed9bc5fb796fe9162e27")!)
            } catch let error {
                // TODO: handle error
                print("ERROR!!!!!! -> \(error)")
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
