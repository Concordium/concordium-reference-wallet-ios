//
// Created by Concordium on 22/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation

struct EncryptionMetadata: Codable {
    let encryptionMethod: String
    let keyDerivationMethod: String
    let iterations: Int
    let salt: String
    let initializationVector: String
    
    init(
        encryptionMethod: String = "AES-256",
        keyDerivationMethod: String = "PBKDF2WithHmacSHA256",
        iterations: Int,
        salt: String,
        initializationVector: String
    ) {
        self.encryptionMethod = encryptionMethod
        self.keyDerivationMethod = keyDerivationMethod
        self.iterations = iterations
        self.salt = salt
        self.initializationVector = initializationVector
    }
}
