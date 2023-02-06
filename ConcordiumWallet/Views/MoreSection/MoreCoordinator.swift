//
// Created by Concordium on 24/04/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import UIKit
import Combine

protocol MoreCoordinatorDelegate: IdentitiesCoordinatorDelegate { }

class MoreCoordinator: Coordinator, ShowAlert {
    typealias DependencyProvider = MoreFlowCoordinatorDependencyProvider & IdentitiesFlowCoordinatorDependencyProvider
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private var dependencyProvider: DependencyProvider
    private var loginDependencyProvider: LoginDependencyProvider
    private var sanityChecker: SanityChecker
    
    weak var delegate: MoreCoordinatorDelegate?
    
    init(navigationController: UINavigationController,
         dependencyProvider: DependencyProvider & LoginDependencyProvider & WalletAndStorageDependencyProvider,
         parentCoordinator: MoreCoordinatorDelegate) {
        self.navigationController = navigationController
        self.dependencyProvider = dependencyProvider
        self.loginDependencyProvider = dependencyProvider
        self.sanityChecker = SanityChecker(mobileWallet: dependencyProvider.mobileWallet(),
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
        self.childCoordinators.append(identitiesCoordinator)
        identitiesCoordinator.showInitial(animated: true)
    }
    
    func showCreateNewIdentity() {
        let identitiesCoordinator = IdentitiesCoordinator(navigationController: navigationController,
                                                          dependencyProvider: dependencyProvider,
                                                          parentCoordinator: self)
        self.childCoordinators.append(identitiesCoordinator)
        identitiesCoordinator.start()
        identitiesCoordinator.showCreateNewIdentity()
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

    func showScanAddressQR() {
        let vc = ScanAddressQRFactory.create(with: ScanAddressQRPresenter(wallet: dependencyProvider.mobileWallet(), delegate: self))
        navigationController.pushViewController(vc, animated: true)
    }

    func showEditRecipient(_ recipient: RecipientDataType) {
        let vc = AddRecipientFactory.create(with: AddRecipientPresenter(delegate: self,
                                                                        dependencyProvider: dependencyProvider,
                                                                        mode: .edit(recipient: recipient)))
        navigationController.pushViewController(vc, animated: true)
    }

//    // MARK: Import
//    func showImport() {
//        let initialAccountPresenter = InitialAccountInfoPresenter(delegate: self, type: .importAccount)
//        let vc = InitialAccountInfoFactory.create(with: initialAccountPresenter)
//        vc.title = initialAccountPresenter.type.getViewModel().title
//        navigationController.pushViewController(vc, animated: true)
//    }
//    
//    // MARK: Export
//    func showExport() {
//        navigationController.popToRootViewController(animated: false)
//        let vc = ExportFactory.create(with: ExportPresenter(dependencyProvider: dependencyProvider, requestPasswordDelegate: self, delegate: self))
//        navigationController.pushViewController(vc, animated: true)
//    }
    
//    func showValidateIdsAndAccounts() {
//        sanityChecker.requestPwAndCheckSanity(requestPasswordDelegate: self,
//                                              keychainWrapper: dependencyProvider.keychainWrapper(),
//                                              mode: .manual)
//    }

    private func showCreateExportPassword() -> AnyPublisher<String, Error> {
        let selectExportPasswordCoordinator = CreateExportPasswordCoordinator(navigationController: TransparentNavigationController(),
                                                                              dependencyProvider: dependencyProvider)
        self.childCoordinators.append(selectExportPasswordCoordinator)
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
        self.childCoordinators.append(updatePasswordCoordinator)
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
    
    func recoverySelected() {
        let recoveryPhraseCoordinator = RecoveryPhraseCoordinator(
            dependencyProvider: ServicesProvider.defaultProvider(),
            navigationController: navigationController,
            delegate: self
        )
        recoveryPhraseCoordinator.start()
        self.navigationController.viewControllers = Array(self.navigationController.viewControllers.lastElements(1))
        childCoordinators.append(recoveryPhraseCoordinator)
        self.navigationController.setupBaseNavigationControllerStyle()
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
        showScanAddressQR()
    }
}

extension MoreCoordinator: AddRecipientPresenterDelegate {
    func addRecipientDidSelectSave(recipient: RecipientDataType) {
        navigationController.popViewController(animated: true)
    }

    func addRecipientDidSelectQR() {
        showScanAddressQR()
    }
}

extension MoreCoordinator: ScanAddressQRPresenterDelegate, AddRecipientCoordinatorHelper {
    func scanAddressQr(didScanAddress address: String) {
        let addRecipientViewController = getAddRecipientViewController(dependencyProvider: dependencyProvider)

        self.navigationController.popToViewController(addRecipientViewController, animated: true)

        addRecipientViewController.presenter.setAccountAddress(address)
    }
}

extension MoreCoordinator: RequestPasswordDelegate {
}

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
                                                       style: .default)] )
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
        self.navigationController.present(vc, animated: true)
    }
    
    func exportFinished() {
        navigationController.popViewController(animated: true)
    }
}

extension MoreCoordinator: AboutPresenterDelegate {}

//extension MoreCoordinator: ImportExport {}

extension MoreCoordinator: IdentitiesCoordinatorDelegate {
    
    func noIdentitiesFound() {
        self.delegate?.noIdentitiesFound()
    }
    
    func finishedDisplayingIdentities() {
        self.childCoordinators.removeAll { coordinator in
            coordinator is CreateExportPasswordCoordinator
        }
    }
}

extension MoreCoordinator: RecoveryPhraseCoordinatorDelegate {
    func recoveryPhraseCoordinator(createdNewSeed seed: Seed) {
        print("+++ recoveryPhraseCoordinator createdNewSeed")
//        showSeedIdentityCreation()
//        childCoordinators.removeAll { $0 is RecoveryPhraseCoordinator }
    }
    
    func recoveryPhraseCoordinatorFinishedRecovery() {
        print("+++ recoveryPhraseCoordinatorFinishedRecovery")
//        showMainTabbar()
//        childCoordinators.removeAll { $0 is RecoveryPhraseCoordinator }
    }
}
