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

class CreateIdentityCoordinator: Coordinator, ShowAlert {
    
    var childCoordinators = [Coordinator]()
    weak var parentCoordinator: CreateNewIdentityDelegate?
    var navigationController: UINavigationController
    private var dependencyProvider: IdentitiesFlowCoordinatorDependencyProvider
    private var cancellables: [AnyCancellable] = []
    private var accountName: String = ""
    /// The identity that is being created. This should hold an object once the user has selected the identity provider.
    /// The IdentityCreation object will be used to create the identity and account entities once the identity provider's flow is completed.
    /// At this point, the object can be dropped.
    private var createdIdentity: IdentityCreation?

    init(navigationController: UINavigationController,
         dependencyProvider: IdentitiesFlowCoordinatorDependencyProvider,
         parentCoordinator: CreateNewIdentityDelegate) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.dependencyProvider = dependencyProvider
    }

    /// Start the identity issuance flow.
    /// This starts with an introductory screen.
    func start() {
        navigationController.modalPresentationStyle = .fullScreen
        showInitialAccountInfo()
        registerForCreatedIdentityNotification()
        registerForApplicationWillTerminateNotification()
    }

    /// Start the identity issuance flow for creating a first account.
    /// This skips the introductory screen and displays the account naming screen with different text.
    func startInitialAccount(withDefaultValuesFrom account: AccountDataType? = nil) {
        navigationController.modalPresentationStyle = .fullScreen
        showCreateNewAccount(withDefaultValuesFrom: account, isInitial: true)
        registerForCreatedIdentityNotification()
        registerForApplicationWillTerminateNotification()
    }
    
    private func registerForApplicationWillTerminateNotification() {
        NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)
            .sink { [weak self] _ in
                self?.cleanupIdentityCreations()
            }.store(in: &cancellables)
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
        guard let (identityCreationId: identityCreationId, pollUrl: pollUrl) =
                ApiConstants.parseCallbackUri(uri: url) else {
            self.handleErrorResponse(url: url)
            return
        }
        do {
            try handleIdentitySubmitted(identityCreationId: identityCreationId, pollUrl: pollUrl)
        } catch {
            Logger.error(error)
            self.showErrorAlert(.genericError(reason: error))
        }

    }

    private func handleIdentitySubmitted(identityCreationId: String, pollUrl: String) throws {
        let storageManager = dependencyProvider.storageManager()
        guard let createdIdentity = createdIdentity, createdIdentity.id == identityCreationId else {
            Logger.error("invalid identity creation id: \(identityCreationId)")
            return
        }
        var newIdentity = IdentityDataTypeFactory.create()
        newIdentity.nickname = createdIdentity.identityName
        newIdentity.identityProvider = createdIdentity.identityProvider
        newIdentity.encryptedPrivateIdObjectData = createdIdentity.encryptedPrivateIdObjectData
        newIdentity.state = .pending
        newIdentity.ipStatusUrl = pollUrl
        try storageManager.storeIdentity(newIdentity)
        var newAccount = AccountDataTypeFactory.create()
        newAccount.name = createdIdentity.initialAccountName
        newAccount.address = createdIdentity.initialAccountAddress
        newAccount.transactionStatus = .committed
        newAccount.encryptedBalanceStatus = .decrypted
        newAccount.encryptedAccountData = createdIdentity.encryptedAccountData
        newAccount.encryptedPrivateKey = createdIdentity.encryptedPrivateKey
        newAccount.identity = newIdentity
        _ = try storageManager.storeAccount(newAccount)
        storageManager.storePendingAccount(with: newAccount.address)
        let shieldedAmount = ShieldedAmountTypeFactory.create().withInitialValue(for: newAccount)
        _ = try storageManager.storeShieldedAmount(amount: shieldedAmount)
        
        self.createdIdentity = nil
        
        navigationController.dismiss(animated: true) { [weak self] in
            self?.showIdentitySubmitted(identity: newIdentity, account: newAccount)
        }
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
            navigationController.dismiss(animated: true) { [weak self] in
                self?.showFailedIdentityCreation(error: serverError)
            }
        }
    }
    
    /// Remove all pending identity creations.
    private func cleanupIdentityCreations() {
        self.createdIdentity = nil
    }

    func showInitialAccountInfo() {
        let initialAccountPresenter = InitialAccountInfoPresenter(delegate: self, type: .newAccount)
        let vc = InitialAccountInfoFactory.create(with: initialAccountPresenter)
        vc.title = initialAccountPresenter.type.getViewModel().title
        navigationController.pushViewController(vc, animated: true)
    }

    func showCreateNewAccount(withDefaultValuesFrom account: AccountDataType? = nil, isInitial: Bool = false) {
        let createNewAccountPresenter = isInitial ?
            CreateNicknamePresenter(withDefaultName: account?.name,
                                    delegate: self,
                                    properties: CreateInitialAccountNicknameProperties()) :
            CreateNicknamePresenter(withDefaultName: account?.name,
                                    delegate: self,
                                    properties: CreateAccountNicknameProperties())
        let vc = CreateNicknameFactory.create(with: createNewAccountPresenter)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showCreateNewIdentity(initialAccountName: String) {
        let vc = CreateNicknameFactory.create(with: CreateNicknamePresenter(delegate: self, properties: CreateIdentityNicknameProperties()))
        navigationController.pushViewController(vc, animated: true)
    }
    
    func nicknameCancelled() {
        parentCoordinator?.createNewIdentityCancelled()
    }

    func showIdentityList(withAccountName accountName: String, withIdentityName identityName: String) {
        let identityProviderListPresenter =
            IdentityProviderListPresenter(dependencyProvider: dependencyProvider,
                                          delegate: self,
                                          accountNickname: accountName,
                                          identityNickname: identityName)
        let vc = IdentityProviderListFactory.create(with: identityProviderListPresenter)
        navigationController.pushViewController(vc, animated: true)
    }

    func showIdentityProviderWebView(urlRequest: URLRequest, createdIdentity: IdentityCreation) {
        self.createdIdentity = createdIdentity
        Logger.debug("Open URL in WKWebView: \(urlRequest.url?.absoluteString ?? "nil")")
        let vc = IdentityProviderWebViewFactory.create(with: IdentityProviderWebViewPresenter(url: urlRequest, delegate: self))
        vc.modalPresentationStyle = .fullScreen
        navigationController.present(vc, animated: true)
    }

    func showIdentitySubmitted(identity: IdentityDataType, account: AccountDataType) {
        let vc = IdentityConfirmedFactory.create(with: IdentityConfirmedPresenter(identity: identity,
                                                                                  account: account,
                                                                                  dependencyProvider: dependencyProvider,
                                                                                  delegate: self))
        showModally(vc, from: navigationController)
    }

    func showFailedIdentityCreation(error: Error) {
        Logger.error(error.localizedDescription)
        let vc = CreationFailedFactory.create(with: CreationFailedPresenter(serverError: error, delegate: self, mode: .identity))
        showModally(vc, from: navigationController)
    }
}

extension CreateIdentityCoordinator: CreateNicknamePresenterDelegate {
    func createNicknamePresenterCancelled(_ presenter: CreateNicknamePresenter) {
        parentCoordinator?.createNewIdentityCancelled()
    }

    func createNicknamePresenter(_: CreateNicknamePresenter,
                                 didCreateName nickname: String,
                                 properties: CreateNicknameProperties) {
        if properties as? CreateAccountNicknameProperties != nil || properties as? CreateInitialAccountNicknameProperties != nil {
            self.accountName = nickname
            showCreateNewIdentity(initialAccountName: nickname)
        } else if properties as? CreateIdentityNicknameProperties != nil {
            self.showIdentityList(withAccountName: self.accountName,
                                  withIdentityName: nickname)
        }
    }
}

extension CreateIdentityCoordinator: IdentitiyProviderListPresenterDelegate {
    func openIdentityProviderInfo(url: URL) {
        let sfSafariViewController = SFSafariViewController(url: url)
        navigationController.present(sfSafariViewController, animated: true)
    }

    func closeIdentityProviderList() {
        cleanupIdentityCreations()
        parentCoordinator?.createNewIdentityCancelled()
    }

    func identityRequestURLGenerated(urlRequest: URLRequest, createdIdentity: IdentityCreation) {
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
        cleanupIdentityCreations()
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
