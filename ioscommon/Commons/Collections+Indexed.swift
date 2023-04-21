//
//  Collections+Indexed.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 01/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

struct Indexed<T>: Identifiable {
    let value: T
    let index: Int
    
    var id: Int { index }
}

extension Sequence {
    func indexed() -> [Indexed<Element>] {
        self.enumerated().map { (index, value) in
            Indexed(value: value, index: index)
        }
    }
}
