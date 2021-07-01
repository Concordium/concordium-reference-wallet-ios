//
//  PasscodeSelectionPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 18/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

protocol CreatePasswordPresenterDelegate: AnyObject {
    func passwordSelectionDone(pwHash: String)
}

class CreatePasswordPresenter: EnterPasswordPresenterProtocol {

    weak var view: EnterPasswordViewProtocol?
    weak var delegate: CreatePasswordPresenterDelegate?
    var viewState: PasswordSelectionState = .selectPasscode
    let dependencyProvider: LoginDependencyProvider

    var selectedPasscode = ""

    init(delegate: CreatePasswordPresenterDelegate, dependencyProvider: LoginDependencyProvider) {
        self.delegate = delegate
        self.dependencyProvider = dependencyProvider
    }

    func viewDidLoad() {
        view?.showKeyboard()
        view?.pincodeDelegate = self
        changeViewState(.selectPasscode, animated: false)
    }

    func viewDidAppear() {

    }

    func passwordEntered(password: String) {
        finishedEnteringPassword(firstState: .selectPassword, secondState: .reenterPassword, password: password)
    }

    func passwordButtonTapped() {
        changeViewState(.selectPassword)
    }

    @objc func backTapped() {
        if viewState == .reenterPassword {
            changeViewState(.selectPassword, reverse: true)
        } else {
            changeViewState(.selectPasscode, reverse: true)
        }
    }

    func changeViewState(_ newState: PasswordSelectionState, animated: Bool = true, reverse: Bool = false) {
        self.viewState = newState
        view?.setState(newState, newPasswordFieldDelegate: self, animated: animated, reverse: reverse)
    }

    private func finishedEnteringPassword(firstState: PasswordSelectionState, secondState: PasswordSelectionState, password: String) {
        if viewState == firstState {
            changeViewState(secondState)
            self.selectedPasscode = password
        } else if viewState == secondState {
            if self.selectedPasscode == password {
                dependencyProvider.keychainWrapper()
                        .storePassword(password: password)
                        .mapError(ErrorMapper.toViewError)
                        .onFailure {
                            changeViewState(firstState)
                            self.view?.showError($0.localizedDescription)
                        }.onSuccess { pwHash in
                            passwordSelected(pwHash: pwHash)
                        }
            } else {
                changeViewState(firstState)
                view?.showError("selectPassword.entryMismatch".localized)
            }
        }
    }

    private func passwordSelected(pwHash: String) {
        let passwordState = viewState == .reenterPassword
        AppSettings.passwordType = passwordState ? .password : .passcode
        self.delegate?.passwordSelectionDone(pwHash: pwHash)
    }
}

extension CreatePasswordPresenter: PasscodeFieldDelegate {
    func pincodeView(_ pincodeView: PasscodeFieldViewController, didFinishEnteringPincode pincode: String) {
        finishedEnteringPassword(firstState: .selectPasscode, secondState: .reenterPasscode, password: pincode)
    }

}

extension CreatePasswordPresenter: PasswordFieldDelegate {
    func setPasswordState(valid: Bool) {
        self.view?.setContinueButtonEnabled(valid)
    }

    func passwordView(_ passwordView: PasswordFieldViewController, didFinishEnteringPassword password: String) {
        passwordEntered(password: password)
    }
}
