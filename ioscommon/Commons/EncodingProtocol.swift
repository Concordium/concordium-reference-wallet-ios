//
//  EncodingProtocol.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 24/09/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation

protocol CBOREncodable {
    var encoded: [UInt8] { get }
}
