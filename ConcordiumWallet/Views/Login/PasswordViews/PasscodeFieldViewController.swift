//
//  PasscodeFieldViewController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 15/03/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import Combine

protocol PasscodeFieldDelegate: AnyObject {
    func pincodeView(_ pincodeView: PasscodeFieldViewController, didFinishEnteringPincode: String)
}

class PasscodeFieldViewController: UIViewController, Storyboarded {
    private let pincodeSize = 6
    weak var delegate: PasscodeFieldDelegate?
    
    private var addingCharacters = false
    private var cancellables: [AnyCancellable] = []

    @IBOutlet var pincodeLabels: [UILabel]! {
        didSet {
            pincodeLabels.forEach { $0.text = "" }
        }
    }
    
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTextField.delegate = self

        passwordTextField.textPublisher.sink { [weak self] pincode in
            self?.pincodeChanged(pincode: pincode)
        }.store(in: &cancellables)
    }

    private func pincodeChanged(pincode: String) {
        displayPincodeInLabels(maskedPincode: mask(pincode))
        if pincode.count == pincodeSize {
            self.delegate?.pincodeView(self, didFinishEnteringPincode: pincode)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passwordTextField.becomeFirstResponder()
    }

    func clear() {
        self.passwordTextField.text = ""
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        displayPincodeInLabels(maskedPincode: "")
    }

    fileprivate func displayPincodeInLabels(maskedPincode: String) {
        let characterArray = Array(maskedPincode)
        for (idx, label) in pincodeLabels.enumerated() {
            label.text = idx < characterArray.count ? String(characterArray[idx]) : ""
        }
    }

    func mask(_ value: String?) -> String {
        // cancel previous calls to mask
        NSObject.cancelPreviousPerformRequests(withTarget: self)

        guard let value = value, value.count > 0 else {return ""}
        if addingCharacters, let lastCharacter = value.last {
            let maskedValue = String(repeating: "*", count: value.count-1)
            
            // mask last entered value after 1 second
            perform(#selector(maskCharactersAfterDelay), with: value, afterDelay: 1)
            
            return "\(maskedValue)\(lastCharacter)"
        } else {
            return String(repeating: "*", count: value.count)
        }
    }
    
    @objc func maskCharactersAfterDelay(_ text: String) {
        displayPincodeInLabels(maskedPincode: String(repeating: "*", count: text.count))
    }
    
    @IBAction func focusButtonTapped(_ sender: Any) {
        passwordTextField.becomeFirstResponder()
    }
}

extension PasscodeFieldViewController: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        addingCharacters = false
        guard let text = textField.text else {return false}

        var textRange = Range(range, in: text)

        if range.location != textField.text?.count ?? 0 {
            // if user has moved the cursor, just move the cursor to the end of the document again and continue
            textField.selectedTextRange = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
            textRange = Range(NSRange(location: text.count, length: 0), in: text)
        }

        if let textRange = textRange {
            let newString = text.replacingCharacters(in: textRange, with: string)
            let acceptingChange = newString.count <= pincodeSize && newString.matches(regex: "^[0-9]*$")
            if acceptingChange && newString.count > text.count { addingCharacters = true }
            return acceptingChange
        }
        return true
    }
}
