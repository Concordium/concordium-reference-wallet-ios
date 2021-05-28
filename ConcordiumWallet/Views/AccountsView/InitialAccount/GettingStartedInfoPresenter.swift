//
//  GettingStartedInfoPresenter.swift
//  ConcordiumWallet
//
//  Concordium on 11/11/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation


// MARK: View
protocol GettingStartedInfoViewProtocol: ShowError {
}

protocol GettingStartedInfoPresenterProtocol: class {
    var view: GettingStartedInfoViewProtocol? { get set }
    func userTappedOK()
}


// MARK: -
// MARK: Delegate
protocol GettingStartedInfoPresenterDelegate: class {
    func userTappedOK()
}

class InitialAccountInfoPresenter {

    weak var view: GettingStartedInfoViewProtocol?
    weak var delegate: GettingStartedInfoPresenterDelegate?
    
    init(delegate: GettingStartedInfoPresenterDelegate? = nil,
         mode: EditRecipientMode) {
        self.delegate = delegate
       
    }
}

extension InitialAccountInfoPresenter: GettingStartedInfoPresenterProtocol {
    func userTappedOK() {
        self.delegate?.userTappedOK()
    }
}
