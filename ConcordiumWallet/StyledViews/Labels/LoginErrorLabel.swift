//
//  LoginErrorLabel.swift
//  ConcordiumWallet
//
//  Created by Concordium on 16/03/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

class LoginErrorLabel: BaseLabel {

    override func initialize() {
        super.initialize()

        font = Fonts.info
        textColor = .errorText
    }
}
