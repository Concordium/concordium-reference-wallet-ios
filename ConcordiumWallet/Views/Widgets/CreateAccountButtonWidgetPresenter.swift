//
//  CreateAccountButtonWidgetPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/22/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import Combine

// MARK: View
protocol CreateAccountButtonWidgetViewProtocol: Loadable, ShowError {
}

// MARK: -
// MARK: Delegate
protocol CreateAccountButtonWidgetPresenterDelegate: AnyObject {
    func createAccountFinished(_ account: AccountDataType)
    func createAccountFailed(error: Error)
}

// MARK: -
// MARK: Presenter
protocol CreateAccountButtonWidgetPresenterProtocol: AnyObject {
	var view: CreateAccountButtonWidgetViewProtocol? { get set }

    func updateData(account: AccountDataType)
    func createAccountTapped()
}

class CreateAccountButtonWidgetPresenter: CreateAccountButtonWidgetPresenterProtocol {

    weak var view: CreateAccountButtonWidgetViewProtocol?
    weak var delegate: (CreateAccountButtonWidgetPresenterDelegate & RequestPasswordDelegate)?

    let service: AccountsServiceProtocol
    let mobileWallet: MobileWalletProtocol
    let storageManager: StorageManagerProtocol
    private var cancellables: [AnyCancellable] = []
    var account: AccountDataType

    init(delegate: (CreateAccountButtonWidgetPresenterDelegate & RequestPasswordDelegate)? = nil,
         dependencyProvider: AccountsFlowCoordinatorDependencyProvider,
         account: AccountDataType) {
        self.delegate = delegate
        service = dependencyProvider.accountsService()
        mobileWallet = dependencyProvider.mobileWallet()
        storageManager = dependencyProvider.storageManager()
        self.account = account
    }

    func updateData(account: AccountDataType) {
        self.account = account
    }

    func createAccountTapped() {
        // Get gathered info from the coordinator
        guard let delegate = self.delegate else { return }
        service.createAccount(account: account, requestPasswordDelegate: delegate)
                .showLoadingIndicator(in: view)
                .tryMap(storageManager.storeAccount)
                .delay(for: 0.1, scheduler: RunLoop.main)
                .sink(receiveError: { [weak self] error in
                    if case NetworkError.serverError = error {
                        Logger.warn("Error: \(error)")
                        self?.delegate?.createAccountFailed(error: error)
                    } else if case GeneralError.userCancelled = error {
                        return
                    } else if let viewError = error as? ViewError {
                        self?.view?.showErrorAlert(viewError)
                    } else {
                        self?.view?.showErrorAlert(ErrorMapper.toViewError(error: error))
                    }
                }, receiveValue: { [weak self] (storedAccount: AccountDataType) in
                    guard let self = self else { return }
                    Logger.debug("received value: \(storedAccount)")
                    self.addAccountToRecipientList(account: self.account)
                    self.delegate?.createAccountFinished(self.account)
                })
                .store(in: &cancellables)

    }

    private func addAccountToRecipientList(account: AccountDataType) {
        var recipient = RecipientDataTypeFactory.create()
        recipient.address = account.address
        recipient.name = account.displayName
        _ = try? self.storageManager.storeRecipient(recipient)
    }
}
