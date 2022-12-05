//
//  SeedIdentityObjectWrapper.swift
//  ConcordiumWallet
//
//  Created by Aleksandar Dimov on 17.11.22.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

struct SeedIdentityObjectWrapper: Codable {
    let v: Int
    let value: SeedIdentityObject
}
