//
//  FungibleToken.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 01/12/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation
import BigInt

/// A structure representing a fungible token with a specified precision.
struct FungibleToken {
    /// The integer value of the token amount.
    var intValue: BigInt
    
    /// The number of decimal places for the token amount.
    let decimals: Int
    
    /// The conversion factor to adjust the display value based on the decimal precision.
    let conversionFactor: BigInt
    
    /// The symbol associated with the fungible token.
    let symbol: String?
    
    /// Initializes a `FungibleToken` instance with a given display value, decimal precision, and optional symbol.
    ///
    /// - Parameters:
    ///   - displayValue: The string representation of the token amount.
    ///   - decimals: The number of decimal places for the token amount.
    ///   - symbol: An optional symbol associated with the fungible token.
    init(displayValue: String, decimals: Int, symbol: String?) {
        let wholePart = BigInt(displayValue.unsignedWholePart)
        let conversionFactor = BigInt(pow(10.0, Double(decimals)))
        let fractionalPart = BigInt(displayValue.fractionalPart(precision: decimals))
        self.conversionFactor = conversionFactor
        self.symbol = symbol
        self.decimals = decimals
        intValue = wholePart * conversionFactor + fractionalPart
    }

    /// A human-readable string representation of the token amount with proper formatting.
    var displayValue: String {
        intValue.format(implicitDecimals: decimals, minDecimals: 3) + " " + (symbol ?? "")
    }
}
