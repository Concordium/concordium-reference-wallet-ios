//
//  ObjectWrapper.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 04/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

struct ObjectWrapper<T: Codable>: Codable {
    let value: T
    let v: Int
}
