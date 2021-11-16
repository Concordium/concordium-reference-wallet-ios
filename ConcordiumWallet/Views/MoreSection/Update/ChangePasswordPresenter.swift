//
//  ChangePasswordPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 11/03/2021.
//  Copyright © 2021 concordium. All rights reserved.
//
import Foundation
import Combine

protocol ChangePasswordPresenterDelegate: AnyObject {
    func passwordSelectionDone(pwHash: String)
    func passwordChangeFailed()
}

class ChangePasswordPresenter: EnterPasswordPresenterProtocol {
    weak var view: EnterPasswordViewProtocol?
    weak var delegate: ChangePasswordPresenterDelegate?
    private var walletAndStorage: WalletAndStorageDependencyProvider
    
    var viewState: PasswordSelectionState = .selectPasscode
    let dependencyProvider: LoginDependencyProvider
    private var cancellables: [AnyCancellable] = []
    private var previousPwHashed: String?
    var selectedPasscode = ""
    var oldPasscodeHashed: String?

    init(delegate: ChangePasswordPresenterDelegate,
         dependencyProvider: LoginDependencyProvider,
         walletAndStorage: WalletAndStorageDependencyProvider,
         oldPasscodeHash: String?) {
        self.delegate = delegate
        self.dependencyProvider = dependencyProvider
        self.walletAndStorage = walletAndStorage
        self.oldPasscodeHashed = oldPasscodeHash
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
    
    private func verifyPasscode(for accounts: [AccountDataType], pwHash: String) throws {
        for account in accounts {
            let result = walletAndStorage.mobileWallet().verifyPasscode(for: account, pwHash: pwHash)
            
            switch result {
            case .failure(let error):
                throw error
            case .success:
                Logger.debug("verified account with address: \(account.address)")
            }
        }
    }
    
    private func updatePasscode(for accounts: [AccountDataType], fromPwHash oldPwHash: String, toPwHash newPwHash: String) throws {
        for account in accounts {
            let result = walletAndStorage.mobileWallet().updatePasscode(for: account,
                                                                        oldPwHash: oldPwHash,
                                                                        newPwHash: newPwHash)
            switch result {
            case .failure(let error):
                throw error
            case .success:
                Logger.debug("successfully reencrypted account with address: \(account.address)")
            }
        }
    }
    
    private func finishedEnteringPassword(firstState: PasswordSelectionState, secondState: PasswordSelectionState, password: String) {
        if viewState == firstState {
            changeViewState(secondState)
            self.selectedPasscode = password
        } else if viewState == secondState {
            if self.selectedPasscode == password {

                self.view?.showActivityIndicator()
  
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if let oldPwHash = self.oldPasscodeHashed {
                    // While password change is in progress, the old password is
                    // keept safe in the keychain. We need this if the process of
                    // reencrypting all accounts is not completed for some reason.
                    // AppCoordinator will complete the transaction from old to new password
                    // on all accounts if, for some very strange reason, the phone crashes in this process.
                    do {

                        // swiftlint:disable line_length
                        let accounts = self.walletAndStorage.storageManager().getAccounts().filter { !$0.isReadOnly && $0.transactionStatus == .finalized }
                            
                        // Verify that the passcode can decrypt all accounts before we start (precondition).
                        try self.verifyPasscode(for: accounts, pwHash: oldPwHash)
                                                
                        // Save old password.
                        let passwordHashed = self.dependencyProvider.keychainWrapper().hashPassword(password)
                        try self.dependencyProvider.keychainWrapper().store(key: KeychainKeys.oldPassword.rawValue,
                                                                            value: oldPwHash,
                                                                            securedByPassword: passwordHashed).get()

                        // Set new password.
                        let storeResult = self.dependencyProvider.keychainWrapper()
                            .storePassword(password: password)
                            .mapError(ErrorMapper.toViewError)
                        switch storeResult {
                        case .failure(let error):
                            self.changeViewState(firstState)
                            self.view?.showError(error.localizedDescription)
                        case .success(let newPwHash):
                            let passwordState = self.viewState == .reenterPassword
                            AppSettings.passwordType = passwordState ? .password : .passcode
                            
                            // Now we are ready to start the (recoverable) transition.
                            AppSettings.passwordChangeInProgress = true
                            try self.updatePasscode(for: accounts, fromPwHash: oldPwHash, toPwHash: newPwHash)
                            self.delegate?.passwordSelectionDone(pwHash: newPwHash)
                        }
                        
                        // Password change was successful.
                        // Remove old password from keychain and set transaction flag false.
                        try self.dependencyProvider.keychainWrapper().deleteKeychainItem(withKey: KeychainKeys.oldPassword.rawValue).get()
                        AppSettings.passwordChangeInProgress = false
                        self.view?.hideActivityIndicator()
                    } catch let error {
                        // Something went wrong trying to re-encrypt all accounts.
                        self.view?.showError(error.localizedDescription)
                        self.delegate?.passwordChangeFailed()
                        self.view?.hideActivityIndicator()
                    }
                }
                }
            } else {
                changeViewState(firstState)
                view?.showError("selectPassword.entryMismatch".localized)
            }
        }
    }
}

extension ChangePasswordPresenter: PasscodeFieldDelegate {
    func pincodeView(_ pincodeView: PasscodeFieldViewController, didFinishEnteringPincode pincode: String) {
        finishedEnteringPassword(firstState: .selectPasscode, secondState: .reenterPasscode, password: pincode)
    }
}

extension ChangePasswordPresenter: PasswordFieldDelegate {
    func setPasswordState(valid: Bool) {
        self.view?.setContinueButtonEnabled(valid)
    }

    func passwordView(_ passwordView: PasswordFieldViewController, didFinishEnteringPassword password: String) {
        passwordEntered(password: password)
    }
}
