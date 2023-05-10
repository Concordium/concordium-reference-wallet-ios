//
//  TermsAndConditionsResponse.swift
//  ConcordiumWallet
//
//  Created by Milan Sawicki on 19/04/2023.
//  Copyright © 2023 concordium. All rights reserved.
//

import Foundation

struct TermsAndConditionsResponse: Codable {
    var url: URL
    var version: String
}
