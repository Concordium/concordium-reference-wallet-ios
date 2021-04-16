//
//  AccountBalanceType.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 04/09/2020.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

enum AccountBalanceTypeEnum: String, Codable {
    case total
    case balance
    case shielded
}
