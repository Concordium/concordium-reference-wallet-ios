//
//  SignMessagePayload.swift
//  ConcordiumWallet
//
//  Created by Michael Olesen on 05/07/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation

// TODO Add binary method (i.e. schema).
struct SignMessagePayload: Codable {
    let message: String
}
