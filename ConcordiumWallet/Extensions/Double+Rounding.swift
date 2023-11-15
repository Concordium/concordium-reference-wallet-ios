//
//  Double+Rounding.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 14/11/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation

extension Double {
    public func rounded(_ rule: FloatingPointRoundingRule, decimals: Int) -> Double {
        let factor = pow(10, Double(decimals))
        return (self * factor).rounded(rule) / factor
    }
}
