//
//  SendFundsAmount.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 01/12/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation
import BigInt

/// Enumeration wrapping different types of tokens amounts that can be sent.

enum SendFundsAmount {
    /// Represents an amount in a CCDs.
    case ccd(GTU)
    /// Represents an amount in a fungible token.
    case fungibleToken(token: FungibleToken)
    /// Represents a non-fungible token.
    case nonFungibleToken(name: String?)

    var intValue: BigInt {
        switch self {
        case let .ccd(gtu):
            return BigInt(gtu.intValue)
        case let .fungibleToken(token: amount):
            return amount.intValue
        case .nonFungibleToken:
            return 1
        }
    }

    /// Returns a human-readable display value for the fund amount.
    var displayValue: String {
        switch self {
        case let .ccd(gtu):
            return gtu.displayValueWithGStroke()
        case let .fungibleToken(token):
            return token.displayValue
        case let .nonFungibleToken(name):
            return name ?? " - "
        }
    }
}
