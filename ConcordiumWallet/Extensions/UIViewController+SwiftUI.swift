//
//  UIViewController+SwiftUI.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 01/06/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import UIKit
import SwiftUI

/// Adds a SwiftUI view to the current view controller.
/// This extension method allows you to easily integrate SwiftUI views into a UIKit-based project.
/// It creates a `UIHostingController` for the provided SwiftUI view and adds it as a child view controller to the current view controller.
/// The SwiftUI view is then embedded within the current view controller's view hierarchy.

///- Parameters:
///    - swiftUIView: The SwiftUI view to be added.
extension UIViewController {
    func addSwiftUIViewToController<Content: View>(_ swiftUIView: Content) {
        let hostingController = UIHostingController(rootView: swiftUIView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            view.bottomAnchor.constraint(equalTo: hostingController.view.bottomAnchor),
            view.rightAnchor.constraint(equalTo: hostingController.view.rightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        hostingController.didMove(toParent: self)
    }
}
