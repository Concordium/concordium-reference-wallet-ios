//
//  BaseNavigationController.swift
//  Foundation
//
//  Created by Valentyn Kovalsky on 22/08/2018.
//  Copyright © 2018 Springfeed. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    var statusBarStyle = UIStatusBarStyle.lightContent

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBaseNavigationControllerStyle()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }

}

extension UINavigationController {
    func setupBaseNavigationControllerStyle() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .barBackground
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.text,
            NSAttributedString.Key.font: Fonts.navigationBarTitle
        ]

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.tintColor = UIColor.barButton
    }
}
