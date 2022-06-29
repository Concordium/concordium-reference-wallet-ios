//
//  AccountPendingChangeType.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 01/04/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

enum AccountPendingChangeType: String, Codable {
    case NoChange
    case ReduceStake
    case RemoveStake
}
