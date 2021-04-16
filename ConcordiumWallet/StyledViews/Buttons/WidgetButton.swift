//
//  WidgetButton.swift
//  ConcordiumWallet
//
//  Created by Mohamed Ghonemi on 4/28/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

class WidgetButton: WidgetView {
    func disable() {
        isUserInteractionEnabled = false
        alpha = 0.4
    }
    
    func enable() {
        isUserInteractionEnabled = true
        alpha = 1
    }
}
