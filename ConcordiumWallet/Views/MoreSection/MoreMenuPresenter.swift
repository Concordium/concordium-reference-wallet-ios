//
//  MoreMenuPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 24/04/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

// MARK: View
protocol MoreMenuViewProtocol: AnyObject {

}

// MARK: -
// MARK: Delegate
protocol MoreMenuPresenterDelegate: AnyObject {
    func identitiesSelected()
    func addressBookSelected()
    func updateSelected()
    func recoverySelected()
    func aboutSelected()
}

// MARK: -
// MARK: Presenter
protocol MoreMenuPresenterProtocol: AnyObject {
	var view: MoreMenuViewProtocol? { get set }
    func viewDidLoad()
    func userSelectedIdentities()
    func userSelectedAddressBook()
    func userSelectedUpdate()
    func userSelectedRecovery()
    func userSelectedAbout()
}

class MoreMenuPresenter {
    weak var view: MoreMenuViewProtocol?
    weak var delegate: MoreMenuPresenterDelegate?

    init(delegate: MoreMenuPresenterDelegate? = nil) {
        self.delegate = delegate
    }

    func viewDidLoad() {
    }
}

extension MoreMenuPresenter: MoreMenuPresenterProtocol {
    func userSelectedIdentities() {
        delegate?.identitiesSelected()
    }
    
    func userSelectedAddressBook() {
        delegate?.addressBookSelected()
    }

    func userSelectedUpdate() {
        delegate?.updateSelected()
    }
    
    func userSelectedRecovery() {
        delegate?.recoverySelected()
    }

    func userSelectedAbout() {
        delegate?.aboutSelected()
    }
}
