//
//  GTUTextFieldDelegate.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 10/05/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import UIKit

class GTUTextFieldDelegate: NSObject, UITextFieldDelegate {
    private let afterTextValidation: (UITextField, Bool) -> Void
    
    init(afterTextValidation: @escaping (UITextField, Bool) -> Void) {
        self.afterTextValidation = afterTextValidation
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString: String) -> Bool {
        let text = (textField.text ?? "") as NSString
        
        let updatedText = text.replacingCharacters(
            in: range,
            with: replacementString
        )
        
        let isValid = GTU.isValid(displayValue: updatedText)
        afterTextValidation(textField, isValid)
        
        return isValid
    }
}
