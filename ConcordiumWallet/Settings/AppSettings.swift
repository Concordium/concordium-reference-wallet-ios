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
    case termsHash
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
    
        
    static let currentTerms = String()
    + "termsAndConditionsScreen.terms1.title".localized
    + "termsAndConditionsScreen.terms2.details".localized
    + "termsAndConditionsScreen.terms3.title".localized
    + "termsAndConditionsScreen.terms4.subtitle".localized
    + "termsAndConditionsScreen.terms5.details".localized
    + "termsAndConditionsScreen.terms6.title".localized
    + "termsAndConditionsScreen.terms7a.details".localized
    + "termsAndConditionsScreen.terms7.paragraph1".localized
    + "termsAndConditionsScreen.terms7.paragraph2".localized
    + "termsAndConditionsScreen.terms7b.details".localized
    + "termsAndConditionsScreen.terms8.title".localized
    + "termsAndConditionsScreen.terms9.details".localized
    + "termsAndConditionsScreen.terms10.title".localized
    + "termsAndConditionsScreen.terms11.details".localized
    + "termsAndConditionsScreen.terms12.title".localized
    + "termsAndConditionsScreen.terms13.details".localized
    + "termsAndConditionsScreen.terms14.title".localized
    + "termsAndConditionsScreen.terms15.details".localized
    + "termsAndConditionsScreen.terms16.title".localized
    + "termsAndConditionsScreen.terms17.details".localized
    + "termsAndConditionsScreen.terms18.title".localized
    + "termsAndConditionsScreen.terms19.details".localized
    + "termsAndConditionsScreen.terms20.title".localized
    + "termsAndConditionsScreen.terms22.details".localized
    + "termsAndConditionsScreen.terms23.subtitle".localized
    + "termsAndConditionsScreen.terms24.details".localized
    + "termsAndConditionsScreen.terms25.title".localized
    + "termsAndConditionsScreen.terms26a.details".localized
    + "termsAndConditionsScreen.terms26.paragraph1".localized
    + "termsAndConditionsScreen.terms26.paragraph2".localized
    + "termsAndConditionsScreen.terms26.paragraph3".localized
    + "termsAndConditionsScreen.terms26b.details".localized
    + "termsAndConditionsScreen.terms27.title".localized
    + "termsAndConditionsScreen.terms28.details".localized
    + "termsAndConditionsScreen.terms29.title".localized
    + "termsAndConditionsScreen.terms30.details".localized
    + "termsAndConditionsScreen.terms31.title".localized
    + "termsAndConditionsScreen.terms32.details".localized
    + "termsAndConditionsScreen.terms33.title".localized
    + "termsAndConditionsScreen.terms34.details".localized
    + "termsAndConditionsScreen.terms35.title".localized
    + "termsAndConditionsScreen.terms36.details".localized
    + "termsAndConditionsScreen.terms37.title".localized
    + "termsAndConditionsScreen.terms38.details".localized
    
    static var termsHash: String? {
        get {
            UserDefaults.standard.string(forKey: UserDefaultKeys.termsHash.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.termsHash.rawValue)
        }
    }
    
    static var iOSVersion: String { UIDevice.current.systemVersion }
    
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
}
