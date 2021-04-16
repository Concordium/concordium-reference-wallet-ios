//
//  BaseNavigationController.swift
//  Foundation
//
//  Created by Valentyn Kovalsky on 22/08/2018.
//  Copyright © 2018 Springfeed. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    var statusBarStyle = UIStatusBarStyle.darkContent

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barTintColor = UIColor.barBackground
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.text,
                                                                  NSAttributedString.Key.font: Fonts.navigationBarTitle]
        navigationBar.tintColor = UIColor.barButton
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }

}


extension UINavigationController {
    func setupBaseNavigationControllerStyle() {
        navigationBar.barTintColor = UIColor.barBackground
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.text,
                                                                  NSAttributedString.Key.font: Fonts.navigationBarTitle]
        navigationBar.tintColor = UIColor.barButton
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
    }
}
