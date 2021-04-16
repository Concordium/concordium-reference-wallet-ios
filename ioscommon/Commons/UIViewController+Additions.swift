//
//  UIViewController+Additions.swift
//  Quiz
//
//  Created by Valentyn Kovalsky on 03/09/2018.
//  Copyright © 2018 Springfeed. All rights reserved.
//

import UIKit

extension UIViewController {
    func topPresented() -> UIViewController? {
        if presentedViewController == nil {
            return self
        }

        return presentedViewController?.topPresented()
    }

    func add(child viewController: UIViewController, inside view: UIView) {
        // Add Child View Controller
        addChild(viewController)

        // Add Child View as Subview
        view.addSubview(viewController.view)

        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }

    func remove(child viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)

        // Remove Child View From Superview
        viewController.view.removeFromSuperview()

        // Notify Child View Controller
        viewController.removeFromParent()
    }
}
