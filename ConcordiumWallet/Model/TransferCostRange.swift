//
//  TransferCostRange.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 20/04/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

struct TransferCostRange {
    let min: TransferCost
    let max: TransferCost
    
    var minCost: GTU {
        GTU(intValue: Int(min.cost) ?? 0)
    }
    
    var maxCost: GTU {
        GTU(intValue: Int(max.cost) ?? 0)
    }
}
