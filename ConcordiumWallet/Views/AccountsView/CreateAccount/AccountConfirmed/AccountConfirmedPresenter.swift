//
//  AccountConfirmedPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/5/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

// MARK: View
protocol AccountConfirmedViewProtocol: AnyObject {
    func bind(title: String, accountViewModel: AccountViewModel)
}

// MARK: -
// MARK: Delegate
protocol AccountConfirmedPresenterDelegate: AnyObject {
    func finish()
}

// MARK: -
// MARK: Presenter
protocol AccountConfirmedPresenterProtocol: AnyObject {
	var view: AccountConfirmedViewProtocol? { get set }
    func viewDidLoad()

    func finish()
}

class AccountConfirmedPresenter: AccountConfirmedPresenterProtocol {

    weak var view: AccountConfirmedViewProtocol?
    weak var delegate: AccountConfirmedPresenterDelegate?

    private var accountViewModel: AccountViewModel
    init(account: AccountDataType, delegate: AccountConfirmedPresenterDelegate? = nil) {
        self.delegate = delegate
        self.accountViewModel = AccountViewModel(account: account, createMode: true)
    }

    func viewDidLoad() {
        let title = "accountConfirmed.title".localized
        view?.bind(title: title, accountViewModel: accountViewModel)
    }

    func finish() {
        delegate?.finish()
    }
}
