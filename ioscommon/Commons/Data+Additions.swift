//
//  Data+Additions.swift
//  ConcordiumWallet
//
//  Created by Kristiyan Dobrev on 23/09/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation

extension Data {
    var bytes: [UInt8] {
        return [UInt8](self)
    }
    
    var hexDescription: String {
        reduce("") {$0 + String(format: "%02x", $1)}
    }
    
    init?(hex: String) {
        let length = hex.count / 2
        var data = Data(capacity: length)
        var index = hex.startIndex
        for _ in 0..<length {
            let j = hex.index(index, offsetBy: 2)
            let bytes = hex[index..<j]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
            index = j
        }
        self = data
    }
}
