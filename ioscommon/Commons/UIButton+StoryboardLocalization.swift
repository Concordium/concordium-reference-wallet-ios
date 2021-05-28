//
//  UIButton+StoryboardLocalization.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/31/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

public extension UIButton {
    @IBInspectable var stringKeyNormal: String {
        get { return "" }
        set {
            let localizedText = newValue.localized
            guard !localizedText.isEmpty else {
                return
            }
            self.setTitle(newValue.localized, for: .normal)
        }
    }
}
