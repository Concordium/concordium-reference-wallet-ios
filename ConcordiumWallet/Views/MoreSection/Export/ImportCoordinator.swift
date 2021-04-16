//
// Created by Johan Rugager Vase on 25/06/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import UIKit
import Combine

protocol ImportCoordinatorDelegate {
    func importCoordinatorDidFinish(_: ImportCoordinator)
    func importCoordinator(_: ImportCoordinator, finishedWithError: Error)
}

class ImportCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private var cancellables: [AnyCancellable] = []
    let dependencyProvider: ImportDependencyProvider
    let importFileUrl: URL
    let parentCoordinator: ImportCoordinatorDelegate?

    init(navigationController: UINavigationController,
         dependencyProvider: ImportDependencyProvider,
         parentCoordinator: ImportCoordinatorDelegate,
         importFileUrl: URL) {
        self.navigationController = navigationController
        self.dependencyProvider = dependencyProvider
        self.importFileUrl = importFileUrl
        self.parentCoordinator = parentCoordinator
    }

    func start() {
        showImport()
    }

    func showImport() {
        let vc = ImportFactory.create()
        vc.modalPresentationStyle = .fullScreen
        navigationController.viewControllers = [vc]
        showEnterImportPassword()
    }

    private func showEnterImportPassword() {
        let presenter = RequestExportPasswordPresenter(delegate: self,
                                                       dependencyProvider: dependencyProvider,
                                                       importFileUrl: importFileUrl)
        let vc = EnterPasswordFactory.create(with: presenter)
        let importPasswordNavigationController = TransparentNavigationController(rootViewController: vc)
        importPasswordNavigationController.modalPresentationStyle = .fullScreen
        navigationController.present(importPasswordNavigationController, animated: true)
    }

    func importData(exportPassword: String, appPassword pwHash: String) throws -> AnyPublisher<ImportedItemsReport, Error> {
        try self.dependencyProvider.importService()
                .importFile(from: self.importFileUrl, pwHash: pwHash, exportPassword: exportPassword)
    }

    private func getAppPasswordAndImportData(exportPassword: String) {
        requestUserPassword(keychain: dependencyProvider.keychainWrapper())
            .tryMap {(pwHash) -> AnyPublisher<ImportedItemsReport, Error> in
                try self.importData(exportPassword: exportPassword, appPassword: pwHash) }
            .flatMap { return $0 }
            .sink(
                receiveError: { [weak self] error in
                    guard let self = self else { return }
                    if case GeneralError.userCancelled = error {
                        self.parentCoordinator?.importCoordinatorDidFinish(self)
                    } else {
                        Logger.error("Error importing file: \(error)")
                        self.parentCoordinator?.importCoordinator(self, finishedWithError: error)
                    }
                },
                receiveValue: { [weak self] (importedItemsReport: ImportedItemsReport?) in
                    guard let self = self, let importedItemsReport = importedItemsReport else { return }
                    self.showImportReceipt(report: importedItemsReport)
            })
            .store(in: &cancellables)
    }

    private func showImportReceipt(report: ImportedItemsReport) {
        let vc = ImportReceiptFactory.create(with: ImportReceiptPresenter(delegate: self))
        vc.modalPresentationStyle = .fullScreen
        self.navigationController.present(vc, animated: true)
        vc.receiptState(report: report)
    }
}

extension ImportCoordinator: RequestExportPasswordPresenterDelegate {
    func finishedEnteringPassword(password: String) {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.getAppPasswordAndImportData(exportPassword: password)
        }
    }

    func passwordSelectionCancelled() {
        self.parentCoordinator?.importCoordinatorDidFinish(self)
    }
}

extension ImportCoordinator: ImportReceiptPresenterDelegate {
    func importReceiptDidFinish() {
        self.parentCoordinator?.importCoordinatorDidFinish(self)
    }
}

extension ImportCoordinator: RequestPasswordDelegate {}
