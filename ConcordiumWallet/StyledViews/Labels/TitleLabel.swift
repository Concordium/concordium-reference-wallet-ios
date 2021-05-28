//
//  TitleLabel.swift
//  ConcordiumWallet
//
//  Created by Concordium on 11/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

class TitleLabel: BaseLabel {

    override func initialize() {
        super.initialize()

        font = Fonts.title
        textColor = .primary
    }
}
