//
//  AccountAddressQRPresenter.swift
//  ConcordiumWallet
//
//  Created by Johan Rugager Vase on 15/04/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

// MARK: View
protocol AccountAddressQRViewProtocol: class {
    func bind(to: AccountAddressViewModel)
}

// MARK: -
// MARK: Delegate
protocol AccountAddressQRPresenterDelegate: class {
    func accountAddressQRPresenterDidFinish(_: AccountAddressQRPresenter)
    func shareButtonTapped()
    func copyButtonTapped()
}

// MARK: -
// MARK: Presenter
protocol AccountAddressQRPresenterProtocol: class {
	var view: AccountAddressQRViewProtocol? { get set }
    func viewDidLoad()
    func closeButtonTapped()
    func shareButtonTapped()
    func copyButtonTapped()
}

class AccountAddressViewModel {
    @Published var accountAddress: String = ""
    @Published var accountName: String = ""
}

class AccountAddressQRPresenter {

    weak var view: AccountAddressQRViewProtocol?
    weak var delegate: AccountAddressQRPresenterDelegate?
    var viewModel = AccountAddressViewModel()

    init(delegate: AccountAddressQRPresenterDelegate?, account: AccountDataType) {
        self.delegate = delegate
        self.viewModel.accountAddress = account.address
        self.viewModel.accountName = account.displayName
    }

    func viewDidLoad() {
        view?.bind(to: viewModel)
    }
}

extension AccountAddressQRPresenter: AccountAddressQRPresenterProtocol {
    func closeButtonTapped() {
        self.delegate?.accountAddressQRPresenterDidFinish(self)
    }

    func shareButtonTapped() {
        self.delegate?.shareButtonTapped()
    }

    func copyButtonTapped() {
        self.delegate?.copyButtonTapped()
    }
}
