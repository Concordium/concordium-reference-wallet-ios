//
//  Digest+Additions.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 12/07/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation
import CryptoKit

extension Digest {
    var bytes: [UInt8] { Array(makeIterator()) }
    
    var data: Data { Data(bytes) }
    
    var hexString: String { bytes.map { String(format: "%02x", $0) }.joined() }
}
