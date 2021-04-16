//
// Created by Johan Rugager Vase on 13/03/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import RealmSwift

enum PasswordType: String {
    case passcode
    case password
}

enum UserDefaultKeys: String {
    case passwordType
    case biometricsEnabled
    case passwordChangeInProgress
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
    #if DEBUG
    static let realmConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    #else
    static let realmConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    #endif
}
