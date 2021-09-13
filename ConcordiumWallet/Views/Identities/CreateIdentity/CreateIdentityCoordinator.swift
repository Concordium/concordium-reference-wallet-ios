//
//  CreateIdentityCoordinator.swift
//  ConcordiumWallet
//
//  Created by Concordium on 14/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import Combine
import SafariServices

protocol CreateNewIdentityDelegate: AnyObject {
    func createNewIdentityFinished()
    func createNewIdentityCancelled()
}

class CreateIdentityCoordinator: Coordinator, ShowError {
    var childCoordinators = [Coordinator]()
    weak var parentCoordinator: CreateNewIdentityDelegate?
    var navigationController: UINavigationController
    private var dependencyProvider: IdentitiesFlowCoordinatorDependencyProvider
    private var cancellables: [AnyCancellable] = []
    private var createdIdentity: IdentityDataType?

    init(navigationController: UINavigationController,
         dependencyProvider: IdentitiesFlowCoordinatorDependencyProvider,
         parentCoordinator: CreateNewIdentityDelegate) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.dependencyProvider = dependencyProvider
    }

    func start() {
        navigationController.modalPresentationStyle = .fullScreen
        showInitialAccountInfo()
        registerForCreatedIdentityNotification()
    }

    func startWithIdentity() {
        navigationController.modalPresentationStyle = .fullScreen
        showCreateNewIdentity()
        registerForCreatedIdentityNotification()
    }
    
    private func registerForCreatedIdentityNotification() {
        // Register for created identity notification (coming from safari controller)
        NotificationCenter.default.publisher(for: .didReceiveIdentityData)
            .sink { [weak self] (notification) in
                if let callback = notification.object as? String {
                    self?.receivedCallback(callback)
                }
            }.store(in: &cancellables)
    }

    private func receivedCallback(_ callback: String) {
        guard let url = URL(string: callback) else {
            Logger.error("wrong url when requesting identity: \(callback)")
            return
        }
        guard let pollUrl = url.absoluteString.components(separatedBy: "#code_uri=").last else {
            handleErrorResponse(url: url)
            return
        }
        do {
            try handleIdentitySubmitted(createdIdentity, pollUrl: pollUrl)
        } catch {
            Logger.error(error)
            self.showErrorAlert(.genericError(reason: error))
        }

    }

    private func handleIdentitySubmitted(_ identity: IdentityDataType?, pollUrl: String) throws {
        guard let createdIdentity = identity else { return }
        let newIdentity = createdIdentity.withUpdated(state: .pending, pollUrl: pollUrl)
        try dependencyProvider.storageManager().storeIdentity(newIdentity)
        identityObjectCreated(createdIdentity)
    }

    private func handleErrorResponse(url: URL) {
        guard let item = url.queryFragments?["error"] else {
            Logger.error("wrong url when requesting identity: \(url.absoluteString)")
            return
        }
        guard let errorString = item.removingPercentEncoding else {
            return
        }
        do {
            try self.parseError(errorString)
        } catch let error {
            Logger.error(error)
            self.showErrorAlert(.genericError(reason: error))
        }
    }
    
    private func parseError(_ errorString: String) throws {
        let error = try IdentityProviderErrorWrapper(errorString)
        if error.error.code == "USER_CANCEL" {
            parentCoordinator?.createNewIdentityCancelled()
        } else {
            let serverError = ViewError.simpleError(localizedReason: error.error.detail)
            createIdentityFailed(serverError)
        }
        createdIdentity = nil
    }
    
    private func cleanupUnfinishedIdentiesAndAccounts() {
        cleanupUnfinishedIdenties()
        cleanupUnfinishedAccounts()
    }
    
    private func cleanupUnfinishedAccounts() {
        let unfinishedAccounts = dependencyProvider.storageManager().getAccounts().filter { $0.address == "" && $0.transactionStatus == .committed}
        for account in unfinishedAccounts {
            dependencyProvider.storageManager().removeAccount(account: account)
        }
    }
    
    private func cleanupUnfinishedIdenties() {
        let unfinishedIdentities = dependencyProvider.storageManager().getIdentities().filter { $0.ipStatusUrl.isEmpty }
        for identity in unfinishedIdentities {
            dependencyProvider.storageManager().removeIdentity(identity)
        }
    }

    func showInitialAccountInfo() {
        let initialAccountPresenter = InitialAccountInfoPresenter(delegate: self, type: .newAccount)
        let vc = InitialAccountInfoFactory.create(with: initialAccountPresenter)
        vc.title = initialAccountPresenter.type.getViewModel().title
        navigationController.pushViewController(vc, animated: true)
    }

    func showCreateNewAccount(withDefaultValuesFrom account: AccountDataType? = nil) {
        let createNewAccountPresenter = CreateNicknamePresenter(withDefaultName: account?.name,
                                                                delegate: self,
                                                                properties: CreateAccountNicknameProperties())
        let vc = CreateNicknameFactory.create(with: createNewAccountPresenter)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showCreateNewIdentity() {
        let vc = CreateNicknameFactory.create(with: CreateNicknamePresenter(delegate: self, properties: CreateIdentityNicknameProperties()))
        navigationController.pushViewController(vc, animated: true)
    }

    func showIdentityList(withIdentityName nickname: String) {
        let identityProviderListPresenter =
            IdentityProviderListPresenter(dependencyProvider: dependencyProvider, delegate: self, identityNickname: nickname)
        let vc = IdentityProviderListFactory.create(with: identityProviderListPresenter)
        navigationController.pushViewController(vc, animated: true)
    }

    func showIdentityProviderWebView(urlRequest: URLRequest, createdIdentity: IdentityDataType) {
        self.createdIdentity = createdIdentity
        Logger.debug("Open URL in WKWebView: \(urlRequest.url?.absoluteString ?? "nil")")
        let vc = IdentityProviderWebViewFactory.create(with: IdentityProviderWebViewPresenter(url: urlRequest, delegate: self))
        vc.modalPresentationStyle = .fullScreen
        navigationController.present(vc, animated: true)
    }

    func showIdentitySubmitted(identity: IdentityDataType) {
        guard let account = dependencyProvider.storageManager().getAccounts(for: identity).first else {
            self.showErrorAlert(.simpleError(localizedReason: "Account association failed"))
            return
        }
        
        let vc = IdentityConfirmedFactory.create(with: IdentityConfirmedPresenter(identity: identity,
                                                                                  account: account,
                                                                                  dependencyProvider: dependencyProvider,
                                                                                  delegate: self))
        showModally(vc, from: navigationController)
    }

    func showFailedIdentityCreation(error: Error) {
        let vc = CreationFailedFactory.create(with: CreationFailedPresenter(serverError: error, delegate: self, mode: .identity))
        showModally(vc, from: navigationController)
    }
}

extension CreateIdentityCoordinator: CreateNicknamePresenterDelegate {
    func createNicknamePresenterCancelled(_ presenter: CreateNicknamePresenter) {
        cleanupUnfinishedAccounts()
        parentCoordinator?.createNewIdentityCancelled()
    }

    func createNicknamePresenter(_ createNicknamePresenter: CreateNicknamePresenter,
                                 didCreateName nickname: String,
                                 properties: CreateNicknameProperties) {
        
        if properties as? CreateAccountNicknameProperties != nil {
            var account = AccountDataTypeFactory.create()
            account.name = nickname
            account.transactionStatus = .committed
            account.encryptedBalanceStatus = .decrypted
            do {
                cleanupUnfinishedAccounts()
                _ = try dependencyProvider.storageManager().storeAccount(account)

            } catch {
                Logger.error(error)
                self.showErrorAlert(.genericError(reason: error))
            }
            showCreateNewIdentity()
        } else if properties as? CreateIdentityNicknameProperties != nil {
            showIdentityList(withIdentityName: nickname)
        }
    }
}

extension CreateIdentityCoordinator: IdentitiyProviderListPresenterDelegate {
    func closeIdentityProviderList() {
        cleanupUnfinishedIdentiesAndAccounts()
        parentCoordinator?.createNewIdentityCancelled()
    }

    func identityRequestURLGenerated(urlRequest: URLRequest, createdIdentity: IdentityDataType) {
        showIdentityProviderWebView(urlRequest: urlRequest, createdIdentity: createdIdentity)
    }
}

extension CreateIdentityCoordinator: IdentityConfirmedPresenterDelegate {
    func identityConfirmedPresenterDidFinish() {
        parentCoordinator?.createNewIdentityFinished()
    }
}

extension CreateIdentityCoordinator: RequestPasswordDelegate {
}

extension CreateIdentityCoordinator {
    func identityObjectCreated(_ result: IdentityDataType) {
        navigationController.dismiss(animated: true) {
            self.showIdentitySubmitted(identity: result)
        }
    }

    func createIdentityFailed(_ error: Error) {
        navigationController.dismiss(animated: true) {
            self.showFailedIdentityCreation(error: error)
        }
    }
}

extension CreateIdentityCoordinator: CreationFailedPresenterDelegate {
    func finish() {
        parentCoordinator?.createNewIdentityFinished()
    }
}

extension CreateIdentityCoordinator: IdentityProviderWebViewPresenterDelegate {
    func identityProviderWebViewPresenterDidClose(_ presenter: IdentityProviderWebViewPresenter) {
        self.navigationController.dismiss(animated: true)
    }

    func identityProviderWebViewPresenter(receivedCallback callback: String) {
        self.receivedCallback(callback)
    }

    func identityProviderWebViewPresenter(failedLoading error: Error) {
        navigationController.dismiss(animated: true) {
            self.showFailedIdentityCreation(error: error)
        }
    }
}

extension CreateIdentityCoordinator: InitialAccountInfoPresenterDelegate {
    func userTappedClose() {
        cleanupUnfinishedIdentiesAndAccounts()
        navigationController.dismiss(animated: true)
    }
    
    func userTappedOK(withType type: InitialAccountInfoType) {
        switch type {
        case .firstAccount:
            break // no action for new account - we shouldn't reach it in this flow
        case .importAccount:
            break // no action for new account - we shouldn't reach it in this flow
        case .newAccount:
            self.showCreateNewAccount()
        case .welcomeScreen:
            break // no action for new account - we shouldn't reach it in this flow
        }
    }
    
}
