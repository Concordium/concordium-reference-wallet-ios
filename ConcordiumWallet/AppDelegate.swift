//
//  AppDelegate.swift
//  ConcordiumWallet
//
//  Created by Concordium on 05/02/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import UIKit
import Combine
import MatomoTracker
import SDWebImageSVGCoder
import SDWebImage

extension Notification.Name {
    static let didReceiveIdentityData = Notification.Name("didReceiveIdentityData")
}

var isRunningTests: Bool {
    return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
}

// @UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private (set) lazy var appCoordinator = AppCoordinator()
    
    private var cancellables = Set<AnyCancellable>()

    private lazy var backgroundWindow: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = BlockingViewController()
        window.windowLevel = .alert
        return window
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        if isRunningTests {
            return true
        }
        application.waitForProtectedData()
            .sink { _ in
                self.startAppCoordinator()
            }
            .store(in: &cancellables)
        
        setupMatomoTracker()
        
        return true
    }
    
    private func startAppCoordinator() {
        window?.rootViewController = appCoordinator.navigationController
        window?.makeKeyAndVisible()
        let SVGCoder = SDImageSVGCoder.shared
        SDImageCodersManager.shared.addCoder(SVGCoder)
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
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        backgroundWindow.isHidden = false
        
        MatomoTracker.shared.dispatch()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        backgroundWindow.isHidden = true
        
        setupMatomoTracker()
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

    // swiftlint:disable line_length
    // Disable third-party keyboards
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
      return extensionPointIdentifier != .keyboard
    }
    
    func setupMatomoTracker() {
        
        MatomoTracker.shared.startNewSession()
        
        var debug: String {
            #if DEBUG
                return "(debug)"
            #else
                return ""
            #endif
        }
        
        var version: String {
            #if MAINNET
            if UserDefaults.bool(forKey: "demomode.userdefaultskey".localized) == true {
                return AppSettings.appVersion + " " + AppSettings.buildNumber + " " + debug
            }
            return AppSettings.appVersion
            #else
            return AppSettings.appVersion + " " + AppSettings.buildNumber + " " + debug
            #endif
        }
        
        MatomoTracker.shared.track(view: ["home", "version and network"])
        
        MatomoTracker.shared.setDimension(version, forIndex: AppConstants.MatomoTracker.versionCustomDimensionId)
        MatomoTracker.shared.setDimension(Net.current.rawValue, forIndex: AppConstants.MatomoTracker.networkCustomDimensionId)
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

struct ProtectedDataFuture: Publisher {
    typealias Output = Void
    typealias Failure = Never
    
    let application: UIApplication
    
    init(application: UIApplication) {
        self.application = application
    }
    
    func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Void == S.Input {
        if application.isProtectedDataAvailable {
            Just(()).receive(subscriber: subscriber)
        } else {
            NotificationCenter.default
                .publisher(for: UIApplication.protectedDataDidBecomeAvailableNotification)
                .first()
                .map { _ in () }
                .receive(subscriber: subscriber)
        }
    }
}

extension UIApplication {
    func waitForProtectedData() -> ProtectedDataFuture {
        return ProtectedDataFuture(application: self)
    }
}
