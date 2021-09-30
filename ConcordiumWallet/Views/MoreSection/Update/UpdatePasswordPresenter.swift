//
//  UpdatePasswordPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 05/03/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation
import Combine

// MARK: View
protocol UpdatePasswordViewProtocol: ShowAlert {
    
}

// MARK: -
// MARK: Delegate
protocol UpdatePasswordPresenterDelegate: AnyObject {
    func showChangePasscode()
    func setPreviousPwHashed(pwHash: String)
}

// MARK: -
// MARK: Presenter
protocol UpdatePasswordPresenterProtocol: AnyObject {
    var view: UpdatePasswordViewProtocol? { get set }
    func viewDidLoad()
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
    
    func userSelectedContinue() {
        delegate?.showChangePasscode()
    }
}
