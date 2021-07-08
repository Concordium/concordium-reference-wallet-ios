//
//  PasscodeFieldViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 15/03/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import Combine

protocol PasswordFieldDelegate: AnyObject {
    func passwordView(_ passwordView: PasswordFieldViewController, didFinishEnteringPassword: String)
    func setPasswordState(valid: Bool)
}

class PasswordFieldViewController: UIViewController, Storyboarded {
    private let leastPasswordSize = 6
    weak var delegate: PasswordFieldDelegate?

    @IBOutlet weak var passwordTextField: UITextField!
    private var cancellables: [AnyCancellable] = []

    func getPassword() -> String? {
        passwordTextField.text
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTextField.delegate = self
    }

    func clear() {
        self.passwordTextField.text = ""
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passwordTextField.becomeFirstResponder()

        passwordTextField.textPublisher.sink { [weak self] pincode in
            guard let self = self else { return }
            self.delegate?.setPasswordState(valid: self.passwordValid(pincode))
        }.store(in: &cancellables)
    }
}

extension PasswordFieldViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let password = self.passwordTextField.text, passwordValid(password) else {
            return false
        }
        delegate?.passwordView(self, didFinishEnteringPassword: password)
        return true
    }

    private func passwordValid(_ password: String?) -> Bool {
        return (password?.count ?? 0) >= leastPasswordSize
    }
}
