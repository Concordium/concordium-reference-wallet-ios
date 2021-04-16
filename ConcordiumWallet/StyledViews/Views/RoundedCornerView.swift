//
//  RoundedCornerView.swift
//  ConcordiumWallet
//
//  Created by Mohamed Ghonemi on 3/4/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

import UIKit

@IBDesignable
class RoundedCornerView: BaseView {

    override func initialize() {
        super.initialize()
        layer.cornerRadius = 4
    }
}
