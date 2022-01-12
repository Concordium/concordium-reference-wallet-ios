//
//  PasscodeSelectionPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 18/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import LocalAuthentication

protocol LoginViewDelegate: AnyObject {
    func loginDone()
}

class LoginPresenter: EnterPasswordPresenterProtocol {
    weak var view: EnterPasswordViewProtocol?
    weak var delegate: LoginViewDelegate?
    let dependencyProvider: LoginDependencyProvider
    let viewState: PasswordSelectionState = AppSettings.passwordType == .password ? .loginWithPassword : .loginWithPasscode
//    let sanityChecker: SanityChecker
    
    init(delegate: LoginViewDelegate, dependencyProvider: LoginDependencyProvider) {
        self.delegate = delegate
        self.dependencyProvider = dependencyProvider
//        self.sanityChecker = SanityChecker(requestPasswordDelegate: self, keychainWrapper: dependencyProvider.keychainWrapper(), mobileWallet: dependencyProvider.mobileWrapper(), storageManager: dependencyProvider.storageManager(), errorDisplayer: <#T##ShowAlert#>, coordinator: <#T##Coordinator#>)
    }

    func viewDidLoad() {
        view?.showKeyboard()
        view?.pincodeDelegate = self
        view?.setState(viewState, newPasswordFieldDelegate: self, animated: false, reverse: false)
        #if DEBUG
        (view as? EnterPasswordViewController)?.showResetButton()
        #endif
    }

    func viewDidAppear() {
        if AppSettings.biometricsEnabled && phoneSettingsBiometricsEnabled() {
            dependencyProvider.keychainWrapper().getPasswordWithBiometrics()
                .onSuccess { pwHash in
                    let passwordCheck = dependencyProvider.keychainWrapper()
                            .checkPasswordHash(pwHash: pwHash)
                    handlePasswordCheck(checkPassword: passwordCheck)
                }
        }
    }

    func phoneSettingsBiometricsEnabled() -> Bool {
        let myContext = LAContext()
        var authError: NSError?
        return myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError)
    }

    func passwordEntered(password: String) {
        let passwordCheck = dependencyProvider.keychainWrapper()
                .checkPassword(password: password)
        handlePasswordCheck(checkPassword: passwordCheck)
    }

    private func handlePasswordCheck(checkPassword: Result<Bool, KeychainError>) {
        checkPassword
                .mapError(ErrorMapper.toViewError)
                .onFailure {
                    view?.setState(viewState, newPasswordFieldDelegate: self, animated: false, reverse: false)
                    view?.showError($0.localizedDescription)}
                .onSuccess { _ in delegate?.loginDone() }
    }
}

extension LoginPresenter: PasscodeFieldDelegate {
    func pincodeView(_ pincodeView: PasscodeFieldViewController, didFinishEnteringPincode pincode: String) {
        passwordEntered(password: pincode)
    }
}

extension LoginPresenter: PasswordFieldDelegate {
    func setPasswordState(valid: Bool) {
        self.view?.setContinueButtonEnabled(valid)
    }

    func passwordView(_ passwordView: PasswordFieldViewController, didFinishEnteringPassword password: String) {
        passwordEntered(password: password)
    }
}
