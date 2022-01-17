//
//  RequestExportPasswordPresenter.swift
//  ConcordiumWallet
//
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
protocol RequestExportPasswordPresenterDelegate: AnyObject {
    func passwordSelectionCancelled()
    func finishedEnteringPassword(password: String)
}

class RequestExportPasswordPresenter: EnterPasswordPresenterProtocol {

    weak var view: EnterPasswordViewProtocol?
    weak var delegate: RequestExportPasswordPresenterDelegate?
    var viewState: PasswordSelectionState = .requestExportPassword
    let dependencyProvider: ImportDependencyProvider
    let importFileUrl: URL

    init(delegate: RequestExportPasswordPresenterDelegate,
         dependencyProvider: ImportDependencyProvider,
         importFileUrl: URL) {
        self.delegate = delegate
        self.dependencyProvider = dependencyProvider
        self.importFileUrl = importFileUrl
    }

    func viewDidLoad() {
        view?.showKeyboard()
        view?.pincodeDelegate = self
        view?.setState(.requestExportPassword,
                       newPasswordFieldDelegate: self,
                       animated: false,
                       reverse: false)
    }

    func viewDidAppear() {

    }

    func passwordEntered(password: String) {
        do {
            try dependencyProvider.importService()
                    .checkPassword(importFile: self.importFileUrl,
                                   exportPassword: password)
            delegate?.finishedEnteringPassword(password: password)
        } catch ImportError.unsupportedEnvironemt(_) {
            view?.showError("import.environmentError".localized)
        } catch ImportError.missingIdentitiesError {
            view?.showError("import.noIdentitiesError".localized)
        } catch {
            view?.showError("import.passwordError".localized)
        }
    }

    @objc func backTapped() {
    }

    func closePasswordViewTapped() {
        delegate?.passwordSelectionCancelled()
    }
}

extension RequestExportPasswordPresenter: PasswordFieldDelegate {
    func setPasswordState(valid: Bool) {
        self.view?.setContinueButtonEnabled(valid)
    }

    func passwordView(_ passwordView: PasswordFieldViewController, didFinishEnteringPassword password: String) {
        passwordEntered(password: password)
    }
}

extension RequestExportPasswordPresenter: PasscodeFieldDelegate {
    func pincodeView(_ pincodeView: PasscodeFieldViewController, didFinishEnteringPincode pincode: String) {
        // Pincode view is not used
    }
}
