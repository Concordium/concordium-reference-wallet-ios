//
//  SignMessagePayload.swift
//  ConcordiumWallet
//
//  Created by Michael Olesen on 05/07/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation

struct SignMessagePayload: Codable {
    let message: String
    let schema: String
}
