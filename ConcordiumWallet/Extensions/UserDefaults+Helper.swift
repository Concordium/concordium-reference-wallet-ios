//
//  UserDefaults+Helper.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 4.11.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import UIKit

extension UserDefaults {
    // Any Object
    class func setObject(_ object: Any, forKey key: String) {
        UserDefaults.standard.set(object, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func object(forKey key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    
    class func removeObject(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    // Bool
    class func setBool(_ value: Bool, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func bool(forKey key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    // Int
    class func setInteger(_ value: Int, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func integer(forKey key: String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }
    
    // Token
    class func setToken(_ token: String) {
        UserDefaults.setObject("Bearer \(token)", forKey: "tokenKey")
    }
    
    class func getToken() -> String? {
        return UserDefaults.object(forKey: "tokenKey") as? String
    }
    
    class func removeToken() {
        UserDefaults.removeObject(forKey: "tokenKey")
    }
    
    // Clear User Defaults
    class func clear() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
}
