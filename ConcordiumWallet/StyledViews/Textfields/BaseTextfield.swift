//
//  Textfield.swift
//  ConcordiumWallet
//
//  Created by Dennis Vexborg Kristensen on 11/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

class BaseTextfield: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.initialize()
    }

    init() {
        super.init(frame: .zero)

        self.initialize()
    }

    func initialize() {
    }
}
