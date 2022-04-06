//
//  RoundedCornerView.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/4/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

import UIKit

@IBDesignable
class RoundedCornerView: BaseView {
    
    override func initialize() {
        super.initialize()
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    func disable() {
        isUserInteractionEnabled = false
        alpha = 0.4
    }
    
    func enable() {
        isUserInteractionEnabled = true
        alpha = 1
    }
    
}
