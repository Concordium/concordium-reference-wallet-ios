//
//  PasscodeSelectionPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 18/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import LocalAuthentication
import Combine

protocol RequestPasswordPresenterDelegate: AnyObject {
    func requestPasswordPresenter(_: RequestPasswordPresenter, didGetPassword: String)
    func failedGettingPassword()
}

class RequestPasswordPresenter: EnterPasswordPresenterProtocol {
    weak var view: EnterPasswordViewProtocol?
    let keychain: KeychainWrapperProtocol
    let viewState: PasswordSelectionState = AppSettings.passwordType == .password ? .requestPassword : .requestPasscode
    let passwordPublisher = PassthroughSubject<String, Error>()
    
    private var cancellables = Set<AnyCancellable>()

    init(keychain: KeychainWrapperProtocol) {
        self.keychain = keychain
    }

    func performBiometricLogin(fallback: @escaping () -> Void) {
        DispatchQueue.main.async {
            // All calls here are blocking - so to make sure that the data passed to "result" PassthroughSubject
            // is actually received, we put this in the end of the dispatch queue
            if AppSettings.biometricsEnabled && self.phoneSettingsBiometricsEnabled() {
                self.keychain.getPasswordWithBiometrics()
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveError: { _ in fallback() },
                        receiveValue: { [weak self] pwHash in
                            self?.receivePWHash(pwHash, fallback: fallback)
                        })
                    .store(in: &self.cancellables)
            } else {
                fallback()
            }
        }
    }
    
    private func receivePWHash(_ pwHash: String, fallback: @escaping () -> Void) {
        let passwordCheck = self.keychain
                .checkPasswordHash(pwHash: pwHash)
                .onFailure { _ in
                    fallback()
                }
        self.handlePasswordCheck(checkPassword: passwordCheck, pwHash: pwHash)
    }

    func viewDidLoad() {
        view?.showKeyboard()
        view?.pincodeDelegate = self
        view?.setState(viewState, newPasswordFieldDelegate: self, animated: false, reverse: false)
    }

    func viewDidAppear() {
    }

    func phoneSettingsBiometricsEnabled() -> Bool {
        let myContext = LAContext()
        var authError: NSError?
        return myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError)
    }

    func closePasswordViewTapped() {
        passwordPublisher.send(completion: .failure(GeneralError.userCancelled))
    }

    func passwordEntered(password: String) {
        let passwordCheck = keychain.checkPassword(password: password)
        let pwHash = keychain.hashPassword(password)
        handlePasswordCheck(checkPassword: passwordCheck, pwHash: pwHash)
    }

    private func handlePasswordCheck(checkPassword: Result<Bool, KeychainError>, pwHash: String) {
        checkPassword
                .mapError(ErrorMapper.toViewError)
                .onFailure { [weak self] in
                    guard let self = self else { return }
                    self.view?.setState(viewState, newPasswordFieldDelegate: self, animated: false, reverse: false)
                    self.view?.showError($0.localizedDescription)
                }
                .onSuccess { [weak self] _ in
                    self?.passwordPublisher.send(pwHash)
                    self?.passwordPublisher.send(completion: .finished)
                }
    }
}

extension RequestPasswordPresenter: PasscodeFieldDelegate {
    func pincodeView(_ pincodeView: PasscodeFieldViewController, didFinishEnteringPincode pincode: String) {
        passwordEntered(password: pincode)
    }
}

extension RequestPasswordPresenter: PasswordFieldDelegate {
    func setPasswordState(valid: Bool) {
        self.view?.setContinueButtonEnabled(valid)
    }

    func passwordView(_ passwordView: PasswordFieldViewController, didFinishEnteringPassword password: String) {
        passwordEntered(password: password)
    }
}
