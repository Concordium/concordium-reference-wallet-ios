//
//  UIScreen+Dimensions.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 1.11.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import UIKit

extension UIScreen {
    class var width: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    class var height: CGFloat {
        return UIScreen.main.bounds.size.height
    }
}
