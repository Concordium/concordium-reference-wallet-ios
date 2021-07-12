//
//  IdentityFailureManager.swift
//  Mock
//
//  Created by Kristiyan Dobrev on 12/07/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation

enum IdentityFailureStatus {
    case retryValidation(identities: [IdentityDataType])
    case retryIdentityCreation(identity: IdentityDataType)
}

protocol IdentityFailureManagerProtocol {
    func identityFailureStatus(identities: [IdentityDataType]) -> IdentityFailureStatus?
}

class IdentityFailureManager: IdentityFailureManagerProtocol {
    
    private let storageManager: StorageManagerProtocol
    
    init(storageManager: StorageManagerProtocol) {
        self.storageManager = storageManager
    }
    
    func identityFailureStatus(identities: [IdentityDataType]) -> IdentityFailureStatus? {
        let failedIdentities = identities.filter { $0.state == .failed }
        
        guard !failedIdentities.isEmpty else {
            return nil
        }
        
        guard failedIdentities.count == 1,
              let identity = failedIdentities.first,
              storageManager.getAccounts(for: identity).count == 1,
              let account = storageManager.getAccounts(for: identity).first,
              account.identity?.state == .failed
        else {
            return .retryValidation(identities: failedIdentities)
        }
        
        return .retryIdentityCreation(identity: identity)
    }
}
