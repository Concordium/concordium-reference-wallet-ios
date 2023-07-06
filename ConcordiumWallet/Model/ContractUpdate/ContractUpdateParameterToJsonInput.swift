//
//  ParameterToJsonInput.swift
//  ConcordiumWallet
//
//  Created by Michael Olesen on 27/06/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation

struct ContractUpdateParameterToJsonInput: Codable {
    let parameter: String
    let receiveName: String
    let schema: Schema
    let schemaVersion: Int?
}
