//
//  SignMessagePayloadToJsonInput.swift
//  ConcordiumWallet
//
//  Created by Michael Olesen on 06/07/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation

struct SignMessagePayloadToJsonInput: Codable {
    let message: String
    let address: String
    let keys: AccountKeys
}

enum SignableValueRepresentation {
    case decoded(String)
    case raw(String)
}
