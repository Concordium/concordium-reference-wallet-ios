//
//  Button.swift
//  ConcordiumWallet
//
//  Created by Concordium on 11/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

class BaseButton: UIButton {

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

    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        self.setBackgroundImage(UIImage(color: color), for: state)
        self.clipsToBounds = true
    }
}
