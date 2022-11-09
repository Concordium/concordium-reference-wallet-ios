//
//  Features.swift
//  ConcordiumWalletTests
//
//  Created by Niels Christian Friis Jakobsen on 01/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

struct FeatureFlag: OptionSet {
    let rawValue: Int
    
    static let recoveryCode = FeatureFlag(rawValue: 1 << 0)
    
    #if DEBUG
    static let enabledFlags: FeatureFlag = [.recoveryCode]
    #else
//    static let enabledFlags: FeatureFlag = []
    static let enabledFlags: FeatureFlag = [.recoveryCode]
    #endif
}
