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
    func importSelected()
    func exportSelected()
    func updateSelected()
    func aboutSelected()
    func validateIdsAndAccountsSelected()
}

// MARK: -
// MARK: Presenter
protocol MoreMenuPresenterProtocol: AnyObject {
	var view: MoreMenuViewProtocol? { get set }
    func viewDidLoad()
    func userSelectedIdentities()
    func userSelectedAddressBook()
    func userSelectedImport()
    func userSelectedExport()
    func userSelectedUpdate()
    func userSelectedValidate()
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

    func userSelectedImport() {
        delegate?.importSelected()
    }
    
    func userSelectedExport() {
        delegate?.exportSelected()
    }

    func userSelectedUpdate() {
        delegate?.updateSelected()
    }
    func userSelectedAbout() {
        delegate?.aboutSelected()
    }
    func userSelectedValidate() {
        delegate?.validateIdsAndAccountsSelected()
    }
}
