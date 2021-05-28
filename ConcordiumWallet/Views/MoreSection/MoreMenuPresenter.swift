//
//  MoreMenuPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 24/04/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

// MARK: View
protocol MoreMenuViewProtocol: class {

}

// MARK: -
// MARK: Delegate
protocol MoreMenuPresenterDelegate: class {
    func addressBookSelected()
    func importSelected()
    func exportSelected()
    func updateSelected()
    func aboutSelected()
}

// MARK: -
// MARK: Presenter
protocol MoreMenuPresenterProtocol: class {
	var view: MoreMenuViewProtocol? { get set }
    func viewDidLoad()
    
    func userSelectedAddressBook()
    func userSelectedImport()
    func userSelectedExport()
    func userSelectedUpdate()
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
}
