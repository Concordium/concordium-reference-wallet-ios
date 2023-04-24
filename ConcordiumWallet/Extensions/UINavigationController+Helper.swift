//
//  UINavigationController+Helper.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 3.11.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    // MARK: - Public
    
    var navigationBarHeight: CGFloat {
        get {
            return navigationBar.frame.size.height;
        }
    }
}
