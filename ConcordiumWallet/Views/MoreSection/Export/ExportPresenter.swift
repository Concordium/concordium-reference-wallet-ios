//
//  ExportPresenter.swift
//  ConcordiumWallet
//
//  Created by Johan Rugager Vase on 25/05/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import Combine

// MARK: View
protocol ExportViewProtocol: ShowError {
}

// MARK: -
// MARK: Delegate
protocol ExportPresenterDelegate: class {
    func shareExportedFile(url: URL, completion: @escaping () -> Void)
    func createExportPassword() -> AnyPublisher<String, Error>
}

// MARK: -
// MARK: Presenter
protocol ExportPresenterProtocol: class {
    var view: ExportViewProtocol? { get set }
    func viewDidLoad()
    func export()
}

class ExportPresenter: ExportPresenterProtocol {

    weak var view: ExportViewProtocol?
    weak var delegate: ExportPresenterDelegate?
    var dependencyProvider: MoreFlowCoordinatorDependencyProvider
    private var cancellables: [AnyCancellable] = []
    private weak var requestPasswordDelegate: RequestPasswordDelegate?

    init(dependencyProvider: MoreFlowCoordinatorDependencyProvider,
         requestPasswordDelegate: RequestPasswordDelegate,
         delegate: ExportPresenterDelegate?) {
        self.delegate = delegate
        self.dependencyProvider = dependencyProvider
        self.requestPasswordDelegate = requestPasswordDelegate
    }

    func viewDidLoad() {

    }

    func export() {
        let exportService: ExportService = self.dependencyProvider.exportService()
        let unfinalizedAccounts = exportService.getUnfinalizedAccounts()
        if unfinalizedAccounts.count > 0 {
            let unfinalizedAccountsNames = unfinalizedAccounts.enumerated().map { "\($0.0 + 1). \($0.1.name)" }
            view?.showRecoverableAlert(ViewError.exportUnfinalizedAccounts(unfinalizedAccountsNames: unfinalizedAccountsNames),
                                       completion: { [weak self] in
                self?.performExport()
            })
        } else {
            performExport()
        }
    }

    private func performExport() {
        self.requestPasswordDelegate?
                       .requestUserPassword(keychain: dependencyProvider.keychainWrapper())
                       .sink(receiveError: {[weak self] error in
                           if case GeneralError.userCancelled = error { return }
                           self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
                       }, receiveValue: { [weak self] pwHash in
                           self?.export(pwHash: pwHash)
                       }).store(in: &cancellables)
    }
    
    private func export(pwHash: String) {
        delegate?.createExportPassword().sink(receiveError: { [weak self] error in
            if case GeneralError.userCancelled = error { return }
            self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
        }, receiveValue: { [weak self] exportPassword in
            self?.export(pwHash: pwHash, exportPassword: exportPassword)
        }).store(in: &cancellables)
    }

    private func export(pwHash: String, exportPassword: String) {
        let exportService: ExportService = self.dependencyProvider.exportService()
        do {
            let url = try exportService.export(pwHash: pwHash, exportPassword: exportPassword)
            self.delegate?.shareExportedFile(url: url, completion: {
                do {
                    Logger.trace("completed - delete export file")
                    try exportService.deleteExportFile()
                } catch {
                    Logger.warn(error)
                    self.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
                }
            })
        } catch {
            Logger.error(error)
        }
    }
}
