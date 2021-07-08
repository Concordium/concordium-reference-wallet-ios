//
//  CreateExportPasswordPresenter.swift
//  ConcordiumWallet
//
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
protocol CreateExportPasswordPresenterDelegate: AnyObject {
    func passwordSelectionDone(password: String)
    func passwordSelectionCancelled()
}

class CreateExportPasswordPresenter: EnterPasswordPresenterProtocol {

    weak var view: EnterPasswordViewProtocol?
    weak var delegate: CreateExportPasswordPresenterDelegate?
    var viewState: PasswordSelectionState = .selectExportPassword

    var selectedPasscode = ""

    init(delegate: CreateExportPasswordPresenterDelegate) {
        self.delegate = delegate
    }

    func viewDidLoad() {
        view?.showKeyboard()
        view?.pincodeDelegate = self
        changeViewState(.selectExportPassword, animated: false)
    }

    func viewDidAppear() {

    }

    func passwordEntered(password: String) {
        finishedEnteringPassword(firstState: .selectExportPassword, secondState: .reenterExportPassword, password: password)
    }

    @objc func backTapped() {
        if viewState == .reenterExportPassword {
            changeViewState(.selectExportPassword, reverse: true)
        }
    }

    func closePasswordViewTapped() {
        delegate?.passwordSelectionCancelled()
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
                self.delegate?.passwordSelectionDone(password: password)
            } else {
                changeViewState(firstState)
                view?.showError("selectPassword.entryMismatch".localized)
            }
        }
    }
}

extension CreateExportPasswordPresenter: PasswordFieldDelegate {
    func setPasswordState(valid: Bool) {
        self.view?.setContinueButtonEnabled(valid)
    }

    func passwordView(_ passwordView: PasswordFieldViewController, didFinishEnteringPassword password: String) {
        passwordEntered(password: password)
    }
}

extension CreateExportPasswordPresenter: PasscodeFieldDelegate {
    func pincodeView(_ pincodeView: PasscodeFieldViewController, didFinishEnteringPincode pincode: String) {
        // Pincode view is not used
    }
}
