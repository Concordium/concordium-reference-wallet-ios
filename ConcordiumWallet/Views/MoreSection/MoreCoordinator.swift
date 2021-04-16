//
// Created by Johan Rugager Vase on 24/04/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import UIKit
import Combine

class MoreCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private var dependencyProvider: MoreFlowCoordinatorDependencyProvider
    private var loginDependencyProvider: LoginDependencyProvider
    
    init(navigationController: UINavigationController,
         dependencyProvider: MoreFlowCoordinatorDependencyProvider & LoginDependencyProvider & WalletAndStorageDependencyProvider) {
        self.navigationController = navigationController
        self.dependencyProvider = dependencyProvider
        self.loginDependencyProvider = dependencyProvider
    }

    func start() {
        showMenu()
    }

    func showMenu() {
        let vc = MoreMenuFactory.create(with: MoreMenuPresenter(delegate: self))
        vc.tabBarItem = UITabBarItem(title: "more_tab_title".localized, image: UIImage(named: "tab_bar_other_icon"), tag: 0)
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

    // MARK: Import
    func showImport() {
        let initialAccountPresenter = InitialAccountInfoPresenter(delegate: self, type: .importAccount)
        let vc = InitialAccountInfoFactory.create(with: initialAccountPresenter)
        vc.title = initialAccountPresenter.type.getViewModel().title
        navigationController.pushViewController(vc, animated: true)
    }
    
    // MARK: Export
    func showExport() {
        let vc = ExportFactory.create(with: ExportPresenter(dependencyProvider: dependencyProvider, requestPasswordDelegate: self, delegate: self))
        navigationController.pushViewController(vc, animated: true)
    }

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
    func addressBookSelected() {
        showAddressBook()
    }

    func importSelected() {
        showImport()
    }
    
    func exportSelected() {
        showExport()
    }
    
    func updateSelected() {
        showUpdatePasscode()
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
    }
    
    func passcodeChangeCanceled() {}

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

extension MoreCoordinator: AboutPresenterDelegate {
    
}
