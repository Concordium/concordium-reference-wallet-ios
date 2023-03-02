//
//  Net.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 03/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum Net: String, Codable {
    case main = "Mainnet"
    case test = "Testnet"
    
    static var current: Net {
        #if MAINNET
        if UserDefaults.bool(forKey: "demomode.userdefaultskey".localized) == true {
            return .test
        }
        return .main
        #else
        return .test
        #endif
    }
}
