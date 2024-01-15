//
//  SendFundsAmount.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 01/12/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import BigInt
import Foundation

/// Enumeration wrapping different types of tokens amounts that can be sent.

enum SendFundsAmount {
    /// Represents an amount in a CCDs.
    case ccd(token: GTU)
    /// Represents an amount in a fungible token.
    case fungibleToken(token: FungibleToken)
    /// Represents a non-fungible token.
    case nonFungibleToken(name: String?)
    /// Represents a state for initial values after screen shows up, or when ie. fractional value for NFT is set.
    /// Helper for UI configuration.
    case none

    var intValue: BigInt {
        switch self {
        case let .ccd(gtu):
            return BigInt(gtu.intValue)
        case let .fungibleToken(token: amount):
            return amount.intValue
        case .nonFungibleToken:
            return 1
        default: return 0
        }
    }

    /// Returns a human-readable display value for the fund amount.
    var displayValue: String {
        switch self {
        case let .ccd(ccd):
            return GTU(intValue: Int(ccd.intValue)).displayValueWithGStroke()
        case let .fungibleToken(token):
            return token.displayValue
        case let .nonFungibleToken(name):
            return name ?? " - "
        case .none:
            return ""
        }
    }
}
