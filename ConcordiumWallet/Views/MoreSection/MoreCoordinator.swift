//
// Created by Concordium on 24/04/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Combine
import Foundation
import UIKit

protocol MoreCoordinatorDelegate: IdentitiesCoordinatorDelegate { }

class MoreCoordinator: Coordinator, ShowAlert, MoreCoordinatorDelegate {
    typealias DependencyProvider = MoreFlowCoordinatorDependencyProvider & IdentitiesFlowCoordinatorDependencyProvider

    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private var dependencyProvider: DependencyProvider
    private var loginDependencyProvider: LoginDependencyProvider
    private var sanityChecker: SanityChecker
    private var accountsCoordinator: AccountsCoordinator?

    weak var delegate: MoreCoordinatorDelegate?

    init(navigationController: UINavigationController,
         dependencyProvider: DependencyProvider & LoginDependencyProvider & WalletAndStorageDependencyProvider,
         parentCoordinator: MoreCoordinatorDelegate) {
        self.navigationController = navigationController
        self.dependencyProvider = dependencyProvider
        loginDependencyProvider = dependencyProvider
        sanityChecker = SanityChecker(mobileWallet: dependencyProvider.mobileWallet(),
                                      storageManager: dependencyProvider.storageManager())
        sanityChecker.errorDisplayer = self
        sanityChecker.coordinator = self
    }

    func start() {
        showMenu()
    }

    func showIdentities() {
        let identitiesCoordinator = IdentitiesCoordinator(navigationController: navigationController,
                                                          dependencyProvider: dependencyProvider,
                                                          parentCoordinator: self)
        childCoordinators.append(identitiesCoordinator)
        identitiesCoordinator.showInitial(animated: true)
    }

    func showCreateNewIdentity() {
        let identitiesCoordinator = IdentitiesCoordinator(navigationController: navigationController,
                                                          dependencyProvider: dependencyProvider,
                                                          parentCoordinator: self)
        childCoordinators.append(identitiesCoordinator)
        identitiesCoordinator.start()
        identitiesCoordinator.showCreateNewIdentity()
    }

    func showScanAddressQR(didScan address: String) {
        let addRecipientViewController = getAddRecipientViewController(dependencyProvider: dependencyProvider)
        self.navigationController.popToViewController(addRecipientViewController, animated: true)
        addRecipientViewController.presenter.setAccountAddress(address)
    }

    func showMenu() {
        let vc = MoreMenuFactory.create(with: MoreMenuPresenter(delegate: self))
        navigationController.pushViewController(vc, animated: false)
    }

    // MARK: Address Book

    func showAddressBook() {
        let vc = SelectRecipientFactory.create(with: SelectRecipientPresenter(delegate: self,
                                                                              storageManager: dependencyProvider.storageManager(),
                                                                              mode: .addressBook))
        navigationController.pushViewController(vc, animated: true)
    }

    func showAddRecipient() {
        let vc = AddRecipientFactory.create(with: AddRecipientPresenter(delegate: self, dependencyProvider: dependencyProvider, mode: .add))
        navigationController.pushViewController(vc, animated: true)
    }

    func showScanAddressQR(didScanQrCode: @escaping ((String) -> Bool)) {
        let vc = ScanQRViewControllerFactory.create(
            with: ScanQRPresenter(didScanQrCode: didScanQrCode, viewWillDisappear: {})
        )
        navigationController.pushViewController(vc, animated: true)
    }

    func showEditRecipient(_ recipient: RecipientDataType) {
        let vc = AddRecipientFactory.create(with: AddRecipientPresenter(delegate: self,
                                                                        dependencyProvider: dependencyProvider,
                                                                        mode: .edit(recipient: recipient)))
        navigationController.pushViewController(vc, animated: true)
    }

    private func showCreateExportPassword() -> AnyPublisher<String, Error> {
        let selectExportPasswordCoordinator = CreateExportPasswordCoordinator(navigationController: TransparentNavigationController(),
                                                                              dependencyProvider: dependencyProvider)
        childCoordinators.append(selectExportPasswordCoordinator)
        selectExportPasswordCoordinator.navigationController.modalPresentationStyle = .fullScreen
        selectExportPasswordCoordinator.start()
        navigationController.present(selectExportPasswordCoordinator.navigationController, animated: true)
        return selectExportPasswordCoordinator.passwordPublisher.eraseToAnyPublisher()
    }

    // MARK: Update password or biometrics

    func showUpdatePasscode() {
        let updatePasswordCoordinator = UpdatePasswordCoordinator(navigationController: navigationController,
                                                                  parentCoordinator: self,
                                                                  requestPasswordDelegate: self,
                                                                  dependencyProvider: loginDependencyProvider,
                                                                  walletAndStorage: dependencyProvider)
        childCoordinators.append(updatePasswordCoordinator)
        updatePasswordCoordinator.start()
    }

    // MARK: About

    func showAbout() {
        let vc = AboutFactory.create(with: AboutPresenter(delegate: self))
        navigationController.pushViewController(vc, animated: true)
    }
}

extension MoreCoordinator: MoreMenuPresenterDelegate {
    func identitiesSelected() {
        showIdentities()
    }

    func addressBookSelected() {
        showAddressBook()
    }

    func updateSelected() {
        showUpdatePasscode()
    }

    func recoverySelected() async throws {
        let pwHash = try await requestUserPassword(keychain: dependencyProvider.keychainWrapper())
        let seedValue = try dependencyProvider.keychainWrapper().getValue(for: "RecoveryPhraseSeed", securedByPassword: pwHash).get()

        let presenter = IdentityRecoveryStatusPresenter(
            recoveryPhrase: nil,
            recoveryPhraseService: nil,
            seed: Seed(value: seedValue),
            pwHash: pwHash,
            identitiesService: dependencyProvider.seedIdentitiesService(),
            accountsService: dependencyProvider.seedAccountsService(),
            keychain: dependencyProvider.keychainWrapper(),
            delegate: self
        )

        replaceTopController(with: presenter.present(IdentityReccoveryStatusView.self))
    }

    private func replaceTopController(with controller: UIViewController) {
        let viewControllers = navigationController.viewControllers.filter { $0.isPresenting(page: RecoveryPhraseGettingStartedView.self) }
        navigationController.setViewControllers(viewControllers + [controller], animated: true)
    }

    func showMainTabbar() {
        navigationController.setupBaseNavigationControllerStyle()

        accountsCoordinator = AccountsCoordinator(
            navigationController: navigationController,
            dependencyProvider: ServicesProvider.defaultProvider(),
            appSettingsDelegate: self,
            accountsPresenterDelegate: self
        )
        accountsCoordinator?.start()
    }

    func aboutSelected() {
        showAbout()
    }
}

extension MoreCoordinator: SelectRecipientPresenterDelegate {
    func didSelect(recipient: RecipientDataType) {
        showEditRecipient(recipient)
    }

    func createRecipient() {
        showAddRecipient()
    }

    func selectRecipientDidSelectQR() {
        showScanAddressQR { [weak self] address in
            // TODO validate
            self?.showScanAddressQR(didScan: address)
            return true
        }
    }
}

extension MoreCoordinator: AddRecipientPresenterDelegate {
    func addRecipientDidSelectSave(recipient: RecipientDataType) {
        navigationController.popViewController(animated: true)
    }

    func addRecipientDidSelectQR() {
        showScanAddressQR { [weak self] address in
            // TODO validate
            self?.showScanAddressQR(didScan: address)
            return true
        }
    }
}

extension MoreCoordinator: AddRecipientCoordinatorHelper {}

extension MoreCoordinator: RequestPasswordDelegate {}

extension MoreCoordinator: InitialAccountInfoPresenterDelegate {
    func userTappedClose() {
        navigationController.popToRootViewController(animated: true)
    }

    func userTappedOK(withType type: InitialAccountInfoType) {
        switch type {
        case .importAccount:
            navigationController.popViewController(animated: true)
        default: break // no action - we shouldn't reach it in this flow
        }
    }
}

extension MoreCoordinator: UpdatePasswordCoordinatorDelegate {
    func passcodeChanged() {
        navigationController.popViewController(animated: false)
        childCoordinators.removeAll(where: { $0 is UpdatePasswordCoordinator })
        let options = AlertOptions(title: "",
                                   message: "more.update.successfully".localized,
                                   actions: [AlertAction(name: "ok".localized,
                                                         completion: {},
                                                         style: .default)])
        showAlert(with: options)
    }
}

extension MoreCoordinator: ExportPresenterDelegate {
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
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
        vc.completionWithItemsHandler = { exportActivityType, completed, _, _ in
            // exportActivityType == nil means that the user pressed the close button on the share sheet

            if completed {
                AppSettings.needsBackupWarning = false
            }

            if completed || exportActivityType == nil {
                completion()
                self.exportFinished()
            }
        }
        navigationController.present(vc, animated: true)
    }

    func exportFinished() {
        navigationController.popViewController(animated: true)
    }
}

extension MoreCoordinator: AboutPresenterDelegate {}

extension MoreCoordinator: IdentitiesCoordinatorDelegate {
    func noIdentitiesFound() {
        delegate?.noIdentitiesFound()
    }

    func finishedDisplayingIdentities() {
        childCoordinators.removeAll { coordinator in
            coordinator is CreateExportPasswordCoordinator
        }
    }
}

extension MoreCoordinator: IdentityRecoveryStatusPresenterDelegate {
    func identityRecoveryCompleted() {
        showMainTabbar()
        childCoordinators.removeAll { $0 is RecoveryPhraseCoordinator }
    }

    func reenterRecoveryPhrase() {
        print("Reenter recovery phrase.")
    }
}

extension MoreCoordinator: AppSettingsDelegate {
    func checkForAppSettings() {
    }
}

extension MoreCoordinator: AccountsPresenterDelegate {

    func createNewIdentity() {
        accountsCoordinator?.showCreateNewIdentity()
    }

    func createNewAccount() {
        accountsCoordinator?.showCreateNewAccount()
    }

    func userPerformed(action: AccountCardAction, on account: AccountDataType) {
        accountsCoordinator?.userPerformed(action: action, on: account)
    }

    func enableShielded(on account: AccountDataType) {
    }

    func noValidIdentitiesAvailable() {
    }

    func tryAgainIdentity() {
    }

    func didSelectMakeBackup() {
    }

    func didSelectPendingIdentity(identity: IdentityDataType) {
    }

    func showSettings() {
        let moreCoordinator = MoreCoordinator(navigationController: navigationController,
                                              dependencyProvider: ServicesProvider.defaultProvider(),
                                              parentCoordinator: self)
        moreCoordinator.start()
    }
}
