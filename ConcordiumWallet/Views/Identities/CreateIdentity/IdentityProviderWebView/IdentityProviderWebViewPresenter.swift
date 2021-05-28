//
//  IdentityProviderWebViewPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 03/06/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

// MARK: View
protocol IdentityProviderWebViewViewProtocol: class {
    func show(url: URLRequest)
}

// MARK: -
// MARK: Delegate
protocol IdentityProviderWebViewPresenterDelegate: class {
    func identityProviderWebViewPresenterDidClose(_: IdentityProviderWebViewPresenter)
    func identityProviderWebViewPresenter(receivedCallback: String)
    func identityProviderWebViewPresenter(failedLoading: Error)
}

// MARK: -
// MARK: Presenter
protocol IdentityProviderWebViewPresenterProtocol: class {
	var view: IdentityProviderWebViewViewProtocol? { get set }
    func viewDidLoad()
    func closeTapped()
    func receivedCallback(_: String)
    func urlFailedToLoad(error: Error)
}

class IdentityProviderWebViewPresenter: IdentityProviderWebViewPresenterProtocol {

    weak var view: IdentityProviderWebViewViewProtocol?
    weak var delegate: IdentityProviderWebViewPresenterDelegate?
    private let url: URLRequest

    init(url: URLRequest, delegate: IdentityProviderWebViewPresenterDelegate? = nil) {
        self.delegate = delegate
        self.url = url
    }

    func viewDidLoad() {
        view?.show(url: url)
    }
    
    func closeTapped() {
        delegate?.identityProviderWebViewPresenterDidClose(self)
    }

    func receivedCallback(_ s: String) {
        Logger.trace("Received WebView callback: \(s)")
        delegate?.identityProviderWebViewPresenter(receivedCallback: s)
    }

    func urlFailedToLoad(error: Error) {
        delegate?.identityProviderWebViewPresenter(failedLoading: error)
    }
}
