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
    /// This variable maintains the owning reference to the nickname presenter
    /// delegate when it is in use.
    private var nicknameWrapper: CreateNicknamePresenterDelegate?

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
        guard let createdIdentity = storageManager.getIdentityCreation(withId: identityCreationId) else {
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
        let shieldedAmount = ShieldedAmountTypeFactory.create().withInitialValue(for: newAccount)
        _ = try storageManager.storeShieldedAmount(amount: shieldedAmount)
        storageManager.removeIdentityCreation(createdIdentity)
        
        identityObjectCreated(newIdentity)
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
    }
    
    private func cleanupIdentityCreations() {
        let storageManager = dependencyProvider.storageManager()
        let identityCreations = storageManager.getIdentityCreations()
        for identityCreation in identityCreations {
            if storageManager.getAccount(withAddress: identityCreation.initialAccountAddress) != nil {
                storageManager.removeIdentityCreation(identityCreation)
            } else {
                storageManager.discardIdentityCreation(identityCreation)
            }
        }
    }

    func showInitialAccountInfo() {
        let initialAccountPresenter = InitialAccountInfoPresenter(delegate: self, type: .newAccount)
        let vc = InitialAccountInfoFactory.create(with: initialAccountPresenter)
        vc.title = initialAccountPresenter.type.getViewModel().title
        navigationController.pushViewController(vc, animated: true)
    }

    func showCreateNewAccount(withDefaultValuesFrom account: AccountDataType? = nil, isInitial: Bool = false) {
        let wrapper = CreateIdentityCoordinatorAccountWrapper(coordinator: self)
        self.nicknameWrapper = wrapper
        let createNewAccountPresenter = isInitial ?
            CreateNicknamePresenter(withDefaultName: account?.name,
                                    delegate: wrapper,
                                    properties: CreateInitialAccountNicknameProperties()) :
            CreateNicknamePresenter(withDefaultName: account?.name,
                                    delegate: wrapper,
                                    properties: CreateAccountNicknameProperties())
        let vc = CreateNicknameFactory.create(with: createNewAccountPresenter)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showCreateNewIdentity(initialAccountName: String) {
        let wrapper = CreateIdentityCoordinatorIdentityWrapper(coordinator: self,
                                                               initialAccountName: initialAccountName)
        self.nicknameWrapper = wrapper
        let vc = CreateNicknameFactory.create(with: CreateNicknamePresenter(delegate: wrapper, properties: CreateIdentityNicknameProperties()))
        navigationController.pushViewController(vc, animated: true)
    }
    
    func nicknameCancelled() {
        self.nicknameWrapper = nil
        parentCoordinator?.createNewIdentityCancelled()
    }

    func showIdentityList(withAccountName accountName: String, withIdentityName identityName: String) {
        self.nicknameWrapper = nil
        let identityProviderListPresenter =
            IdentityProviderListPresenter(dependencyProvider: dependencyProvider,
                                          delegate: self,
                                          accountNickname: accountName,
                                          identityNickname: identityName)
        let vc = IdentityProviderListFactory.create(with: identityProviderListPresenter)
        navigationController.pushViewController(vc, animated: true)
    }

    func showIdentityProviderWebView(urlRequest: URLRequest, createdIdentity: IdentityCreationDataType) {
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

/// A wrapper for the CreateIdentityCoordinator to act as a CreateNicknamePresenterDelegate
/// for obtaining the account name.
class CreateIdentityCoordinatorAccountWrapper {
    private weak var coordinator: CreateIdentityCoordinator?
    init(coordinator: CreateIdentityCoordinator) {
        self.coordinator = coordinator
    }
}

extension CreateIdentityCoordinatorAccountWrapper: CreateNicknamePresenterDelegate {
    func createNicknamePresenterCancelled(_: CreateNicknamePresenter) {
        coordinator?.nicknameCancelled()
    }
    
    func createNicknamePresenter(_: CreateNicknamePresenter,
                                 didCreateName nickname: String,
                                 properties: CreateNicknameProperties) {
        coordinator?.showCreateNewIdentity(initialAccountName: nickname)
    }
}

/// A wrapper for the CreateIdentityCoordinator to act as a CreateNicknamePresenterDelegate
/// for obtaining the identity name.
class CreateIdentityCoordinatorIdentityWrapper {
    private weak var coordinator: CreateIdentityCoordinator?
    let initialAccountName: String
    init(coordinator: CreateIdentityCoordinator, initialAccountName: String) {
        self.coordinator = coordinator
        self.initialAccountName = initialAccountName
    }
}

extension CreateIdentityCoordinatorIdentityWrapper: CreateNicknamePresenterDelegate {
    func createNicknamePresenterCancelled(_: CreateNicknamePresenter) {
        coordinator?.parentCoordinator?.createNewIdentityCancelled()
    }
    
    func createNicknamePresenter(_: CreateNicknamePresenter,
                                 didCreateName nickname: String,
                                 properties: CreateNicknameProperties) {
        coordinator?.showIdentityList(withAccountName: initialAccountName,
                                      withIdentityName: nickname)
    }
}

extension CreateIdentityCoordinator: IdentitiyProviderListPresenterDelegate {
    func closeIdentityProviderList() {
        cleanupIdentityCreations()
        parentCoordinator?.createNewIdentityCancelled()
    }

    func identityRequestURLGenerated(urlRequest: URLRequest, createdIdentity: IdentityCreationDataType) {
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
