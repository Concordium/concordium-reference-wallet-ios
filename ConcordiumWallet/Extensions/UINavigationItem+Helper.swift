//
//  UINavigationItem+Helper.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 2.11.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationItem {
    
    // MARK: - Public
    
    // Hide back bar button item text
    func hideBackBarButtonItemText() {
        backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
