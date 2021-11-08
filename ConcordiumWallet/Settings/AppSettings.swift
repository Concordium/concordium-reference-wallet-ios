//
// Created by Concordium on 13/03/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import UIKit

enum PasswordType: String {
    case passcode
    case password
}

enum UserDefaultKeys: String {
    case passwordType
    case biometricsEnabled
    case passwordChangeInProgress
    case dontShowMemoAlertWarning
    case pendingAccount
}

struct AppSettings {
    static var passwordType: PasswordType? {
        get {
            guard let string = UserDefaults.standard.string(forKey: UserDefaultKeys.passwordType.rawValue) else {
                return nil
            }
            return PasswordType.init(rawValue: string)
        }
        set {
            UserDefaults.standard.set(newValue?.rawValue, forKey: UserDefaultKeys.passwordType.rawValue)
        }
    }

    static var biometricsEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: UserDefaultKeys.biometricsEnabled.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.biometricsEnabled.rawValue)
        }
    }

    static var passwordChangeInProgress: Bool {
        get {
            if UserDefaults.standard.object(forKey: UserDefaultKeys.passwordChangeInProgress.rawValue) == nil {
                AppSettings.passwordChangeInProgress = false
            }
            return UserDefaults.standard.bool(forKey: UserDefaultKeys.passwordChangeInProgress.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.passwordChangeInProgress.rawValue)
        }
    }
    
    static var dontShowMemoAlertWarning: Bool {
        get {
            UserDefaults.standard.bool(forKey: UserDefaultKeys.dontShowMemoAlertWarning.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.dontShowMemoAlertWarning.rawValue)
        }
    }
    
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    static var iOSVersion: String { UIDevice.current.systemVersion }
    
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
}
