//
//  CreationFailedPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/5/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

enum CreationFailedUIMode {
    case account
    case identity
    case transfer
}

// MARK: View
protocol CreationFailedViewProtocol: AnyObject {
    func set(errorTitle: String)
    func set(errorMessage: String)
    func set(viewControllerTitle: String)
}

// MARK: -
// MARK: Delegate
protocol CreationFailedPresenterDelegate: AnyObject {
    func finish()
}

// MARK: -
// MARK: Presenter
protocol CreationFailedPresenterProtocol: AnyObject {
	var view: CreationFailedViewProtocol? { get set }
    func viewDidLoad()

    func finish()
}

class CreationFailedPresenter: CreationFailedPresenterProtocol {
    var serverError: Error?
    
    weak var view: CreationFailedViewProtocol?
    weak var delegate: CreationFailedPresenterDelegate?
    
    private var mode: CreationFailedUIMode

    init(serverError: Error, delegate: CreationFailedPresenterDelegate? = nil, mode: CreationFailedUIMode) {
        if case NetworkError.serverError = serverError {
            self.serverError = ErrorMapper.toViewError(error: serverError)
        } else if case ViewError.simpleError = serverError {
            self.serverError = serverError
        }
        self.mode = mode
        self.delegate = delegate
    }

    func viewDidLoad() {
        if let serverError = self.serverError {
            view?.set(errorMessage: serverError.localizedDescription)
        }
        switch mode {
            case .account:
                view?.set(errorTitle: "accountFailed.title".localized)
                view?.set(viewControllerTitle: "creationFailed.account".localized)
            case .identity:
                view?.set(errorTitle: "identityFailed.title".localized)
                view?.set(viewControllerTitle: "creationFailed.identity".localized)
            case .transfer:
                view?.set(errorTitle: "transactionFailed.title".localized)
                view?.set(viewControllerTitle: "creationFailed.transfer".localized)
        }
    }

    func finish() {
        delegate?.finish()
    }
}
