//
//  Environment.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 19.12.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum Environment: String, Codable {
    case main = "production"
    case test = "prod_testnet"
    case staging = "staging"
    
    static var current: Environment {
        #if MAINNET
        if UserDefaults.bool(forKey: "demomode.userdefaultskey".localized) == true {
            return .test
        }
        return .main
        #elseif TESTNET
        return .test
        #elseif STAGINGNET
        return .staging
        #else // Mock
        return ""
        #endif
    }
}
