//
//  RevealAttributesPresenter.swift
//  ConcordiumWallet
//
//  Concordium on 17/11/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import Combine

// MARK: View
protocol RevealAttributesViewProtocol: Loadable, ShowAlert {
}

// MARK: -
// MARK: Delegate
protocol RevealAttributesPresenterDelegate: CreateAccountButtonWidgetPresenterDelegate {
    func revealAttributes(_ account: AccountDataType)
    func revealPresentedCanceled()
}

// MARK: -
// MARK: Presenter
protocol RevealAttributesPresenterProtocol: AnyObject {
    var view: RevealAttributesViewProtocol? { get set }
    func viewDidLoad()
    
    func closeButtonPressed()
    func finish()
    func revealAttributes()
}

class RevealAttributesPresenter: RevealAttributesPresenterProtocol {
    var serverError: Error?
    
    weak var view: RevealAttributesViewProtocol?
    weak var delegate: (RevealAttributesPresenterDelegate & RequestPasswordDelegate)?
    
    private let account: AccountDataType
    private let service: AccountsServiceProtocol
    private let storageManager: StorageManagerProtocol
    private var cancellables: [AnyCancellable] = []
    
    init(account: AccountDataType,
         dependencyProvider: AccountsFlowCoordinatorDependencyProvider,
         delegate: (RevealAttributesPresenterDelegate & RequestPasswordDelegate)? = nil) {
        self.delegate = delegate
        self.account = account
        service = dependencyProvider.accountsService()
        storageManager = dependencyProvider.storageManager()
    }
    
    func viewDidLoad() {
    }

    func revealAttributes() {
        delegate?.revealAttributes(account)
    }
    func finish() {
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
                } else if case KeychainError.itemNotFound = error {
                    let alert = AlertOptions(title: "identitymissingkeyserror.title".localized,
                                             message: "identitymissingkeyserror.details".localized,
                                             actions: [AlertAction(name: "identitymissingkeyserror.okay".localized,
                                                                   completion: {},
                                                                   style: .default)] )
                    self?.view?.showAlert(with: alert)
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
    
    func closeButtonPressed() {
        self.delegate?.revealPresentedCanceled()
    }
    
    private func addAccountToRecipientList(account: AccountDataType) {
        var recipient = RecipientDataTypeFactory.create()
        recipient.address = account.address
        recipient.name = account.displayName
        _ = try? self.storageManager.storeRecipient(recipient)
    }
}
