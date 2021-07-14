//
//  IdentityFailureManager.swift
//  Mock
//
//  Created by Kristiyan Dobrev on 12/07/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation
import CryptoKit

protocol IdentityFailureManagerProtocol {
    func hasFailedIdentities(identities: [IdentityDataType]) -> Bool
    func hash(codeUri: String) -> String?
}

class IdentityFailureManager: IdentityFailureManagerProtocol {
    
    private let storageManager: StorageManagerProtocol
    
    init(storageManager: StorageManagerProtocol) {
        self.storageManager = storageManager
    }
    
    func hasFailedIdentities(identities: [IdentityDataType]) -> Bool {
        let failedIdentities = identities.filter { $0.state == .failed }
        return !failedIdentities.isEmpty
    }
    
    func hash(codeUri: String) -> String? {
        guard let data = codeUri.data(using: .utf8) else { return nil }
        let digest = SHA256.hash(data: data)
        return digest.hexString
    }
}
