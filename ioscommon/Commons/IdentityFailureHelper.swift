//
//  IdentityFailureHelper.swift
//  Mock
//
//  Created by Kristiyan Dobrev on 12/07/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation
import CryptoKit

struct IdentityFailureHelper {
    static func hash(codeUri: String) -> String? {
        guard let data = codeUri.data(using: .utf8) else { return nil }
        let digest = SHA256.hash(data: data)
        return digest.hexString
    }
}
