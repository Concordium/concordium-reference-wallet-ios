//
//  SeedIDRequest.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 04/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

struct SeedIDRequest: Codable {
    let idObjectRequest: ObjectWrapper<IDRequestV1.IDObjectRequest>
    let redirectURI: String
}
