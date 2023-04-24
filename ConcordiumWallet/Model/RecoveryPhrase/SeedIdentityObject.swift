//
//  SeedIdentityObject.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 05/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

struct SeedIdentityObject: Codable {
    let signature: String
    let attributeList: AttributeList
    let preIdentityObject: IDRequestV1.IDObjectRequest
}
