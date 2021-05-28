//
//  TransparentNavigationController.swift
//  ConcordiumWallet
//
//  Created by Concordium on 19/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//
import UIKit

class TransparentNavigationController: BaseNavigationController {

    override func viewDidLoad() {
        navigationBar.barTintColor = .clear
        navigationBar.isTranslucent = true
        view.backgroundColor = .clear
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.buttonText,
                                             NSAttributedString.Key.font: Fonts.navigationBarTitle]
        statusBarStyle = .lightContent
    }
}
