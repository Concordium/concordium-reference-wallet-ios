//
// Created by Concordium on 14/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()

    func showModally(_ vc: UIViewController, from navContrller: UINavigationController)
}

extension Coordinator {
    /// Handle showing modally the view controller right if presented from navigation controller (by wrapping
    /// It inside a navigation controller)
    func showModally(_ vc: UIViewController, from navController: UINavigationController) {
        let presentedNavController = BaseNavigationController(rootViewController: vc)
        presentedNavController.modalPresentationStyle = .fullScreen
        navController.present(presentedNavController, animated: true, completion: nil)
    }
}
