//
//  FungibleToken.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 01/12/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import BigInt
import Foundation

/// A structure representing a fungible token with a specified precision.
///

enum FungibleTokenParseError: Error {
    case invalidInput
    case negativeDecimals
    case fractionPartTooLong
    var localizedDescription: String {
        switch self {
        case .invalidInput:
            return "Unable to parse. Unexpected input."
        case .negativeDecimals:
            return "Unable to parse. Input can't be negative value."
        case .fractionPartTooLong:
            return "Number of decimal digits exceeds token capability."
        }
    }
}

struct FungibleToken {
    /// The integer value of the token amount.
    var intValue: BigInt

    /// The number of decimal places for the token amount.
    let decimals: Int

//    /// The conversion factor to adjust the display value based on the decimal precision.
//    let conversionFactor: BigInt

    /// The symbol associated with the fungible token.
    let symbol: String?

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
        let decimalSeparator = NumberFormatter().decimalSeparator!

        let sep = decimalSeparator[decimalSeparator.startIndex]
        // Covers scenario when user inputs a value with decimal separator
        if let idx = input.firstIndex(of: sep) {
            let wholePart = input[input.startIndex ..< idx]
            let idx1 = input.index(idx, offsetBy: 1)
            let fracPart = input[idx1 ..< input.endIndex]
            guard let wholePartInt = BigInt(String(wholePart)), let fracPartInt = BigInt(String(fracPart)) else {
                throw FungibleTokenParseError.invalidInput
            }
            guard decimals > fracPart.count else {
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

    private static func multiplyWithPowerOfTen(int: BigInt, exponent: Int) -> BigInt {
        var input = int
        for _ in 1 ... exponent {
            input *= 10
        }
        return input
    }

    /// A human-readable string representation of the token amount with proper formatting.
    var displayValue: String {
        intValue.format(implicitDecimals: decimals, minDecimals: 3) + " " + (symbol ?? "")
    }
}
