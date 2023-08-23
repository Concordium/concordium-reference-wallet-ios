//
//  CIS2TokenSelectionRepresentible.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 22/08/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation

struct CIS2TokenSelectionRepresentable: Hashable {
    var tokenId: String
    var balance: Int
    var isSelected = false
    var details: CIS2TokenDetails
}
