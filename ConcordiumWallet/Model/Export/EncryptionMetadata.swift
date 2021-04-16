//
// Created by Johan Rugager Vase on 22/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation

struct EncryptionMetadata: Codable {
        let encryptionMethod: String = "AES-256"
        let keyDerivationMethod: String = "PBKDF2WithHmacSHA256"
        let iterations: Int
        let salt: String
        let initializationVector: String
}
