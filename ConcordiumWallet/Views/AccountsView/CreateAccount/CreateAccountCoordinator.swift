//
//  CreateIdentityCoordinator.swift
//  ConcordiumWallet
//
//  Created by Dennis Vexborg Kristensen on 14/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

protocol CreateNewAccountDelegate: class {
    func createNewAccountFinished()
    func createNewAccountCancelled()
}

class CreateAccountCoordinator: Coordinator {
    weak var parentCoordinator: CreateNewAccountDelegate?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private var dependencyProvider: AccountsFlowCoordinatorDependencyProvider

    var createButtonWidgetPresenter: CreateAccountButtonWidgetPresenter?

    init(navigationController: UINavigationController,
         dependencyProvider: AccountsFlowCoordinatorDependencyProvider,
         parentCoordinator: CreateNewAccountDelegate) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.dependencyProvider = dependencyProvider

        self.navigationController.modalPresentationStyle = .fullScreen
    }

    func start() {
        start(withDefaultValuesFrom: nil)
    }

    func start(withDefaultValuesFrom account: AccountDataType?) {
        showCreateNewAccount(withDefaultValuesFrom: account)
    }

    func showCreateNewAccount(withDefaultValuesFrom account: AccountDataType? = nil) {
        let createNewAccountPresenter = CreateNicknamePresenter(withDefaultName: account?.name,
                                                                delegate: self,
                                                                properties: CreateAccountNicknameProperties())
        let vc = CreateNicknameFactory.create(with: createNewAccountPresenter)
        navigationController.viewControllers = [vc]
    }

    func showChooseIdentity(withName name: String) {
        let identityChoosePresenter = IdentityChoosePresenter(dependencyProvider: dependencyProvider, delegate: self, nickname: name)
        let chooseIdentityPresenter = IdentitiesFactory.create(with: identityChoosePresenter, flow: .createAccount)
        navigationController.pushViewController(chooseIdentityPresenter, animated: true)
    }

    func showAllowIdentitySelection(for account: AccountDataType) {
        
    }
    
    func showIdentityAttributeSelection(for account: AccountDataType) {
        let baseInfoPresenter = IdentityBaseInfoWidgetPresenter(identity: account.identity!)
        let baseInfoVc = IdentityBaseInfoWidgetFactory.create(with: baseInfoPresenter)

        let identitySelectionPresenter = IdentityDataSelectionWidgetPresenter(delegate: self, account: account)
        let dataSelectionVC = IdentityDataSelectionWidgetFactory.create(with: identitySelectionPresenter)
        let vc = WidgetViewController.instantiate(fromStoryboard: "Widget")
        vc.title = "add_identity_data".localized
        vc.add(viewControllers: [baseInfoVc, dataSelectionVC])

        createButtonWidgetPresenter = CreateAccountButtonWidgetPresenter(delegate: self, dependencyProvider: dependencyProvider, account: account)
        let footerVC = CreateAccountButtonWidgetFactory.create(with: createButtonWidgetPresenter!)
        vc.addToFooter(viewControllers: [footerVC])
        // Add the close button
        vc.addRightBarButton(iconName: "close_icon") {
            self.navigationController.dismiss(animated: true, completion: nil)
        }
        navigationController.pushViewController(vc, animated: true)
    }

    func showRevealAttributes(for account: AccountDataType) {
        let vc = RevealAttributesFactory.create(with: RevealAttributesPresenter(account: account, dependencyProvider: dependencyProvider, delegate: self))
      
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showAccountConfirmed(_ account: AccountDataType) {
        let vc = AccountConfirmedFactory.create(with: AccountConfirmedPresenter(account: account, delegate: self))
        showModally(vc, from: navigationController)
    }

    func showAccountFailed(error: Error) {
        let vc = CreationFailedFactory.create(with: CreationFailedPresenter(serverError: error, delegate: self, mode: .account))
        showModally(vc, from: navigationController)
    }
}

extension CreateAccountCoordinator: CreateNicknamePresenterDelegate {
    func createNicknamePresenterCancelled(_ createNicknamePresenter: CreateNicknamePresenter) {
        parentCoordinator?.createNewAccountCancelled()
    }

     func createNicknamePresenter(_: CreateNicknamePresenter, didCreateName nickname: String, properties: CreateNicknameProperties) {
        showChooseIdentity(withName: nickname)
    }
}

extension CreateAccountCoordinator: IdentityChoosePresenterDelegate {
    func chooseIdentityPresenterCancelled(_ chooseIdentityPresenter: IdentityChoosePresenter) {
        parentCoordinator?.createNewAccountCancelled()
    }

    func identitySelected(for account: AccountDataType) {
        //Set the account create info
        showRevealAttributes(for: account)
    }
}

extension CreateAccountCoordinator: IdentityDataSelectionWidgetPresenterDelegate {
    func userChangeSelected(account: AccountDataType) {
        createButtonWidgetPresenter?.updateData(account: account)
    }
}

extension CreateAccountCoordinator: CreateAccountButtonWidgetPresenterDelegate {
    func createAccountFinished(_ account: AccountDataType) {
        showAccountConfirmed(account)
    }

    func createAccountFailed(error: Error) {
        showAccountFailed(error: error)
    }
}

extension CreateAccountCoordinator: AccountConfirmedPresenterDelegate, CreationFailedPresenterDelegate {
    func finish() {
        parentCoordinator?.createNewAccountFinished()
    }
}

extension CreateAccountCoordinator: RevealAttributesPresenterDelegate  {
    func revealAttributes(_ account: AccountDataType) {
        showIdentityAttributeSelection(for: account)
    }
    
    func revealPresentedCanceled() {
        parentCoordinator?.createNewAccountCancelled()
    }
}


extension CreateAccountCoordinator: RequestPasswordDelegate {
}
