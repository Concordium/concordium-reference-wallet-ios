//
//  BaseTabBar.swift
//  ConcordiumWallet
//
//  Created by Concordium on 14/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBar.barTintColor = .background
        tabBar.tintColor = .primary
        tabBar.unselectedItemTintColor = .text
    }
}
