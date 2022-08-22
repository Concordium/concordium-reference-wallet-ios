//
//  GenerateRecoveryRequestInput.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 18/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

struct GenerateRecoveryRequestInput: Codable {
    let ipInfo: IPInfoV1
    let global: Global
    let timestamp: Int
    let seed: Seed
    let net: Net
    let identityIndex: Int
}
