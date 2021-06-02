//
//  AppDelegate.swift
//  ConcordiumWallet
//
//  Created by Concordium on 05/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let didReceiveIdentityData = Notification.Name("didReceiveIdentityData")
}

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var appCoordinator = AppCoordinator()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        window?.rootViewController = appCoordinator.navigationController
        window?.makeKeyAndVisible()

        // Warn if device is jail broken.
        if UIDevice.current.isJailBroken {
            let ac = UIAlertController(title: "Warning", message: "error", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "errorAlert.okButton".localized, style: .default) { (_) in
                self.appCoordinator.start()
            }
            ac.addAction(okAction)
            appCoordinator.navigationController.present(ac, animated: true)
        } else {
            appCoordinator.start()
        }

        // Listen for application timeout. 
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.receivedApplicationTimeout),
                                               name: .didReceiveAppTimeout,
                                               object: nil)
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        Logger.trace("application:openUrl: \(url)")
        if url.absoluteString.starts(with: ApiConstants.notabeneCallback) {
            receivedCreateIdentityCallback(url)
        } else {
            // importing file
            appCoordinator.importWallet(from: url)
        }
        return true
    }

    // Disable third-party keyboards
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
      return extensionPointIdentifier != .keyboard
    }
}

extension AppDelegate {
    func receivedCreateIdentityCallback(_ url: URL) {
        let url = url.absoluteString
        NotificationCenter.default.post(name: .didReceiveIdentityData, object: url)
    }
    
    @objc func receivedApplicationTimeout() {
        appCoordinator.logout()
    }
}
