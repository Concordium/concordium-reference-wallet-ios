//
//  Seed.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 04/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

struct Seed: Codable {
    let value: String
    
    init(value: String) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        value = try container.decode(String.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(value)
    }
}
