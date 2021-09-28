//
//  GettingStartedPresenter.swift
//  ConcordiumWallet
//
//  Concordium on 11/11/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

// MARK: View
protocol GettingStartedViewProtocol: ShowAlert {
}

protocol GettingStartedPresenterProtocol: AnyObject {
    var view: GettingStartedViewProtocol? { get set }
    func userTappedCreateAccount()
    func userTappedImport()
}

// MARK: -
// MARK: Delegate
protocol GettingStartedPresenterDelegate: AnyObject {
    func userTappedCreateAccount()
    func userTappedImport()
}

class GettingStartedPresenter {

    weak var view: GettingStartedViewProtocol?
    weak var delegate: GettingStartedPresenterDelegate?
    
    init(delegate: GettingStartedPresenterDelegate? = nil) {
        self.delegate = delegate
    }
}

extension GettingStartedPresenter: GettingStartedPresenterProtocol {
    func userTappedCreateAccount() {
        self.delegate?.userTappedCreateAccount()
    }
    
    func userTappedImport() {
        self.delegate?.userTappedImport()
    }
}
