//
//  IdentityConfirmedPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/5/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

// MARK: View
protocol IdentityConfirmedViewProtocol: AnyObject {
    func bind(title: String, subtitle: String, details: String, accountViewModel: AccountViewModel, identityViewModel: IdentityDetailsInfoViewModel)
}

// MARK: -
// MARK: Delegate
protocol IdentityConfirmedPresenterDelegate: AnyObject {
    func identityConfirmedPresenterDidFinish()
}

// MARK: -
// MARK: Presenter
protocol IdentityConfirmedPresenterProtocol: AnyObject {
    var view: IdentityConfirmedViewProtocol? { get set }
    func viewDidLoad()

    func finish()

    var identityAuthorityName: String { get set }
}

class IdentityConfirmedPresenter: IdentityConfirmedPresenterProtocol {

    weak var view: IdentityConfirmedViewProtocol?
    weak var delegate: IdentityConfirmedPresenterDelegate?

    var identityAuthorityName: String
    var identity: IdentityDataType
    var account: AccountDataType
    private var dependencyProvider: IdentitiesFlowCoordinatorDependencyProvider
    private var accountViewModel: AccountViewModel
    private var identityViewModel: IdentityDetailsInfoViewModel

    init(identity: IdentityDataType,
         account: AccountDataType,
         dependencyProvider: IdentitiesFlowCoordinatorDependencyProvider,
         delegate: IdentityConfirmedPresenterDelegate? = nil) {
        self.identityAuthorityName = identity.identityProviderName ?? ""
        self.identity = identity
        self.account = account
        self.delegate = delegate
        self.dependencyProvider = dependencyProvider
        accountViewModel = AccountViewModel(account: account, createMode: true)
        identityViewModel = IdentityDetailsInfoViewModel(identity: identity)
    }

    func viewDidLoad() {
        view?.bind(title: "identitySubmitted.title".localized,
                subtitle: "identitySubmitted.heading".localized,
                details: "identitySubmitted.details".localized,
                accountViewModel: accountViewModel,
                identityViewModel: identityViewModel)
    }

    func finish() {
        delegate?.identityConfirmedPresenterDidFinish()
    }
}
