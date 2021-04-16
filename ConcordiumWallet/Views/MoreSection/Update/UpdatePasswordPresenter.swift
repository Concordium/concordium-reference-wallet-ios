//
//  UpdatePasswordPresenter.swift
//  ConcordiumWallet
//
//  Created by Carsten Nørby on 05/03/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation
import Combine

// MARK: View
protocol UpdatePasswordViewProtocol: ShowError {
    
}

// MARK: -
// MARK: Delegate
protocol UpdatePasswordPresenterDelegate: class {
    func cancelChangePassword()
    func showChangePasscode()
    func setPreviousPwHashed(pwHash: String)
}

// MARK: -
// MARK: Presenter
protocol UpdatePasswordPresenterProtocol: class {
    var view: UpdatePasswordViewProtocol? { get set }
    func viewDidLoad()
    func closeButtonPressed()
    func userSelectedContinue()
}

class UpdatePasswordPresenter: UpdatePasswordPresenterProtocol {

    weak var view: UpdatePasswordViewProtocol?
    weak var delegate: UpdatePasswordPresenterDelegate?
    
    init(delegate: UpdatePasswordPresenterDelegate) {
        self.delegate = delegate
    }

    func viewDidLoad() {
    }
    
    func closeButtonPressed() {
        delegate?.cancelChangePassword()
    }
    
    func userSelectedContinue() {
        delegate?.showChangePasscode()
    }
}
