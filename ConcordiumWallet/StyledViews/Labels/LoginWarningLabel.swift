//
//  LoginWarningLabel.swift
//  ConcordiumWallet
//
//  Created by Dennis Vexborg Kristensen on 18/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

class LoginWarningLabel: BaseLabel {

    override func initialize() {
        super.initialize()

        font = Fonts.info
        textColor = .whiteText
    }
}
