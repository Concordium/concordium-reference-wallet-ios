//
//  GenerateRecoveryRequestOutput.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 18/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

struct GenerateRecoveryRequestOutput: Codable {
    let idRecoveryRequest: ObjectWrapper<IDRecoveryRequest>
}

struct IDRecoveryRequest: Codable {
    let idCredPub: String
    let proof: String
    let timestamp: Int
}
