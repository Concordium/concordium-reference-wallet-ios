//
//  UILabel+localized.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/29/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

public extension UILabel {
    @IBInspectable var stringKey: String? {
        get {
            return text
        }
        set {
            text = NSLocalizedString(newValue ?? "", comment: "")
        }
    }
}
