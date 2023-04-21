//
//  CreateSeedCredentialRequest.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 10/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

struct CreateSeedCredentialRequest: Codable {
    let ipInfo: IPInfoV1
    let arsInfos: [String: ARSInfoV1]
    let global: Global
    let identityObject: SeedIdentityObject
    let revealedAttributes: [String]
    let identityIndex: Int
    let accountNumber: Int
    let seed: Seed
    let net: Net
    let expiry: Int
}
