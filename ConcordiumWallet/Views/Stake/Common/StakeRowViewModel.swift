//
//  StakeRowViewModel.swift
//  ConcordiumWallet
//
//  Created by Ruxandra Nistor on 23/03/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

class StakeRowViewModel: Hashable {
    var headerLabel: String
    var valueLabel: String
    
    init(displayValue: DisplayValue) {
        headerLabel = displayValue.key
        valueLabel = displayValue.value
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(headerLabel)
    }
    static func == (lhs: StakeRowViewModel, rhs: StakeRowViewModel) -> Bool {
        return lhs.headerLabel == rhs.headerLabel
    }
}
