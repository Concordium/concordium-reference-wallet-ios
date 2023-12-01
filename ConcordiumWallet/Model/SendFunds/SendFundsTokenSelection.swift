//
//  SendFundsTokenType.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 01/12/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation

/// Represents currently selected type of token to be transfered on transfer screen.
enum SendFundsTokenSelection: Equatable {
    case ccd
    case cis2(token: CIS2TokenSelectionRepresentable)
}
