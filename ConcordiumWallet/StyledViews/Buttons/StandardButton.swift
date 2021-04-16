//
//  StandardButton.swift
//  ConcordiumWallet
//
//  Created by Dennis Vexborg Kristensen on 11/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

@IBDesignable
class StandardButton: BaseButton {

    override func initialize() {
        super.initialize()

        titleLabel?.font = Fonts.buttonTitle
        setTitleColor(.buttonText, for: .normal)
        backgroundColor = .primary
        layer.cornerRadius = 4
        setBackgroundColor(.inactiveButton, for: .disabled)
    }
}
