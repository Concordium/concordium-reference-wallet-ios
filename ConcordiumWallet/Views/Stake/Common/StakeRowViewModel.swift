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
    private var field: Field
    
    init(entry: StakeData) {
        headerLabel = entry.getKeyLabel()
        valueLabel = entry.getDisplayValue()
        field = entry.field
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(field.getLabelText())
    }
    static func == (lhs: StakeRowViewModel, rhs: StakeRowViewModel) -> Bool {
        return lhs.field == rhs.field
    }
}
