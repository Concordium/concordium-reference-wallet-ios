//
//  BiometricsEnablingPresenter.swift
//  ConcordiumWallet
//
//  Created by Concordium on 06/04/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import LocalAuthentication
import Combine

// MARK: View
protocol BiometricsEnablingViewProtocol: AnyObject {

}

// MARK: -
// MARK: Delegate
protocol BiometricsEnablingPresenterDelegate: AnyObject {
    func biometricsEnablingDone()
}

// MARK: -
// MARK: Presenter
protocol BiometricsEnablingPresenterProtocol: AnyObject {
    var view: BiometricsEnablingViewProtocol? { get set }
    func viewDidLoad()
    func enablePressed()
    func continueWithoutBiometrics()
    func getBiometricType() -> LABiometryType
}

class BiometricsEnablingPresenter: BiometricsEnablingPresenterProtocol {

    weak var view: BiometricsEnablingViewProtocol?
    weak var delegate: BiometricsEnablingPresenterDelegate?
    private let keychain: KeychainWrapperProtocol

    private let pwHash: String
    
    private var cancellables = Set<AnyCancellable>()

    init(delegate: BiometricsEnablingPresenterDelegate? = nil, pwHash: String, dependencyProvider: LoginDependencyProvider) {
        self.delegate = delegate
        self.pwHash = pwHash
        self.keychain = dependencyProvider.keychainWrapper()
    }

    func viewDidLoad() {

    }

    func enablePressed() {
        if biometricsEnabled() {
            let myContext = LAContext()
            let myLocalizedReasonString: String
            switch getBiometricType() {
            case .faceID:
                myLocalizedReasonString = "selectPassword.biometrics.infoText.faceIdText".localized
            case .touchID:
                myLocalizedReasonString = "selectPassword.biometrics.infoText.touchIdText".localized
            default:
                myLocalizedReasonString = ""
            }

            // Hide "Enter Password" button
            myContext.localizedFallbackTitle = ""

            myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                    localizedReason: myLocalizedReasonString) { success, _ in
                DispatchQueue.main.async {
                    if success {
                        self.keychain.storePasswordBehindBiometrics(pwHash: self.pwHash)
                            .receive(on: DispatchQueue.main)
                            .sink(receiveError: { _ in }, receiveValue: { [weak self] _ in
                                AppSettings.biometricsEnabled = true
                                self?.delegate?.biometricsEnablingDone()
                            })
                            .store(in: &self.cancellables)
                    }
                }
            }
        }
    }
    
    func continueWithoutBiometrics() {
        AppSettings.biometricsEnabled = false
        self.delegate?.biometricsEnablingDone()
    }

    func biometricsEnabled() -> Bool {
        let myContext = LAContext()
        var authError: NSError?
        return myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError)
    }
    
    func getBiometricType() -> LABiometryType {
        let myContext = LAContext()
        var authError: NSError?
        if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            return myContext.biometryType
        } else {
            return .none
        }
    }
}
