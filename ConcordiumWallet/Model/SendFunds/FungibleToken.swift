//
//  FungibleToken.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 01/12/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import BigInt
import Foundation

enum FungibleTokenParseError: Error {
    case invalidInput
    case negativeDecimals
    case fractionPartTooLong
    case inputTooLarge

    var localizedDescription: String {
        switch self {
        case .invalidInput:
            return "Unable to parse. Unexpected input."
        case .negativeDecimals:
            return "Unable to parse. Input can't be negative value."
        case .fractionPartTooLong:
            return "Too many fractional digits."
        case .inputTooLarge:
            return "Input too large."
        }
    }
}

/// A structure representing a fungible token with a specified precision.
struct FungibleToken {
    /// The integer value of the token amount.
    var intValue: BigInt

    /// The number of decimal places for the token amount.
    let decimals: Int

    /// The symbol associated with the fungible token.
    let symbol: String?

    private static let decimalSeparator = NumberFormatter().decimalSeparator!
    /// Initializes a `FungibleToken` instance with a given display value, decimal precision, and optional symbol.
    ///
    /// - Parameters:
    ///   - value: Token amount as BigInt.
    ///   - decimals: The number of decimal places for the token amount.
    ///   - symbol: An optional symbol associated with the fungible token.
    static func parse(input: String, decimals: Int, symbol: String?) throws -> FungibleToken {
        guard decimals > 0 else {
            throw FungibleTokenParseError.negativeDecimals
        }

        let sep = decimalSeparator[decimalSeparator.startIndex]
        // Covers scenario when user inputs a value with decimal separator
        if let idx = input.firstIndex(of: sep) {
            let wholePart = input[input.startIndex ..< idx]
            let idx1 = input.index(idx, offsetBy: 1)
            let fracPart = input[idx1 ..< input.endIndex]
            guard let wholePartInt = BigInt(String(wholePart)), let fracPartInt = BigInt(String(fracPart)) else {
                throw FungibleTokenParseError.invalidInput
            }
            guard fracPart.count <= decimals else {
                throw FungibleTokenParseError.fractionPartTooLong
            }
            let multipliedWholeInt = multiplyWithPowerOfTen(int: wholePartInt, exponent: decimals)
            let multipliedFractionInt = multiplyWithPowerOfTen(int: fracPartInt, exponent: decimals - fracPart.count)
            return FungibleToken(intValue: multipliedWholeInt + multipliedFractionInt, decimals: decimals, symbol: symbol)
        }

        guard let int = BigInt(input) else {
            throw FungibleTokenParseError.invalidInput
        }
        return FungibleToken(
            intValue: multiplyWithPowerOfTen(
                int: int,
                exponent: decimals
            ),
            decimals: decimals,
            symbol: symbol
        )
    }

    private static func multiplyByPowerOfTen(n: BigInt, power: Int) -> BigInt {
        var input = int
        for _ in 0 ..< exponent {
            input *= 10
        }
        return input
    }

    /// A human-readable string representation of the token amount with proper formatting.
    var displayValue: String {
        let s = formattedString(subunitPrecision: decimals, minDecimalDigits: 3)
        if let symbol {
            return "\(s) \(symbol)"
        }
        return s
    }
    
    /// Formats the `BigInt` with a specified number of implicit decimals and a minimum number of decimals.
    ///
    /// - Parameters:
    ///   - subunitPrecision: The number of digits that are interpreted as fractional.
    ///   - minDecimalDigits: The minimum number of digits.
    /// - Returns: A string representation of the formatted `BigInt`.
    func formattedString(subunitPrecision: Int, minDecimalDigits: Int) -> String {
        var val = intValue
        var decimals = subunitPrecision
        while decimals > minDecimalDigits && val % 10 == 0 {
            val /= 10
            decimals -= 1
        }
        return format(value: val, subunitPrecision: decimals)
    }
    
    private func format(value: BigInt, subunitPrecision: Int) -> String {
        if subunitPrecision == 0 {
            return String(intValue)
        }
        var val = value
        var sign = ""
        if val < 0 {
            val = abs(val)
            sign = "-"
        }
        let decimalSeparator = NumberFormatter().decimalSeparator!
        let divisor = BigInt(10).power(subunitPrecision)
        let int = String(val / divisor)
        let frac = String(val % divisor)
        let padding = String(repeating: "0", count: subunitPrecision - frac.count)
        
        return "\(sign)\(int)\(decimalSeparator)\(padding)\(frac)"
    }
}
