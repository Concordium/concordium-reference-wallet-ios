//
// Created by Concordium on 14/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

@MainActor
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
    
    func share(
        items activityItems: [URL] = [],
        activities applicationActivities: [UIActivity] = [],
        from navController: UINavigationController,
        completion: @escaping (Bool) -> Void
    ) {
        let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        vc.completionWithItemsHandler = { exportActivityType, completed, _, _ in
            // exportActivityType == nil means that the user pressed the close button on the share sheet
            if completed || exportActivityType == nil {
                completion(completed)
            }
        }
        navController.present(vc, animated: true)
    }
}
