//
//  HashingHelper.swift
//
//  Created by Kristiyan Dobrev on 12/07/2021.
//  Copyright © 2021 concordium. All rights reserved.
//
import Foundation
import CryptoKit

struct HashingHelper {
    static func hash(_ text: String) -> String? {
        guard let data = text.data(using: .utf8) else { return nil }
        let digest = SHA256.hash(data: data)
        return digest.hexString
    }
}
