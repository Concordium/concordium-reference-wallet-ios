//
//  BaseView.swift
//  ConcordiumWallet
//
//  Created by Concordium on 12/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

class BaseView: UIView {

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
