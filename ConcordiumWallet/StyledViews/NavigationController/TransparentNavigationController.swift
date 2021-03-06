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
        setupTransparentNavigationControllerStyle()
        view.backgroundColor = .clear
        statusBarStyle = .lightContent
    }

}

extension UINavigationController {
    func setupTransparentNavigationControllerStyle() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.buttonText,
            NSAttributedString.Key.font: Fonts.navigationBarTitle
        ]

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }
}
