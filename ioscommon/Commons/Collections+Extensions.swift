//
//  Collections+Extensions.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 01/07/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

extension Collection {
    func lastElements(_ elementCount: Int) -> DropFirstSequence<Self> {
        let amountToDrop = Swift.max(self.count - 1, 0)
        
        return dropFirst(amountToDrop)
    }
}
