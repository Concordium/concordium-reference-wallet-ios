//
//  IdentityCreationEntity.swift
//  ConcordiumWallet
//
//  Created by Concordium on 23/09/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation
import RealmSwift

protocol IdentityCreationDataType: DataStoreProtocol {
    /// Unique identifier for the identity creation object
    var id: String { get }
    /// Name of the initial account
    var initialAccountName: String { get }
    /// Address of the initial account
    var initialAccountAddress: String { get }
    /// Name of the identity
    var identityName: String { get }
    /// Key for the stored account data object
    var encryptedAccountData: String { get }
    /// Key for the stored private key
    var encryptedPrivateKey: String { get }
    /// Key for the stored private ID object data
    var encryptedPrivateIdObjectData: String { get }
    /// The identity provider used to create the identity
    var identityProvider: IdentityProviderDataType? { get }

}

struct IdentityCreationDataTypeFactory {
    static func create(initialAccountName: String,
                       initialAccountAddress: String,
                       identityName: String,
                       encryptedAccountData: String,
                       encryptedPrivateKey: String,
                       encryptedPrivateIdObjectData: String,
                       identityProvider: IdentityProviderDataType) -> IdentityCreationDataType {
        IdentityCreationEntity(initialAccountName: initialAccountName,
                               initialAccountAddress: initialAccountAddress,
                               identityName: identityName,
                               encryptedAccountData: encryptedAccountData,
                               encryptedPrivateKey: encryptedPrivateKey,
                               encryptedPrivateIdObjectData: encryptedPrivateIdObjectData,
                               identityProvider: identityProvider as? IdentityProviderEntity ?? IdentityProviderEntity())
    }
}

final class IdentityCreationEntity: Object {
    /// Identifier for the identity creation entity (primary key)
    @objc dynamic var id = NSUUID().uuidString
    /// Name of the initial account
    @objc dynamic var initialAccountName: String = ""
    /// Address of the initial account
    @objc dynamic var initialAccountAddress: String = ""
    /// Name of the identity
    @objc dynamic var identityName: String = ""
    /// Key for the stored account data object
    @objc dynamic var encryptedAccountData: String = ""
    /// Key for the stored private key
    @objc dynamic var encryptedPrivateKey: String = ""
    /// Key for the stored private ID object data
    @objc dynamic var encryptedPrivateIdObjectData: String = ""
    /// The identity provider used in creating the identity
    @objc dynamic var identityProviderEntity: IdentityProviderEntity? = IdentityProviderEntity()
    
    override init() {
        
    }
    
    init(initialAccountName: String,
         initialAccountAddress: String,
         identityName: String,
         encryptedAccountData: String,
         encryptedPrivateKey: String,
         encryptedPrivateIdObjectData: String,
         identityProvider: IdentityProviderEntity) {
        self.initialAccountName = initialAccountName
        self.initialAccountAddress = initialAccountAddress
        self.identityName = identityName
        self.encryptedAccountData = encryptedAccountData
        self.encryptedPrivateKey = encryptedPrivateKey
        self.encryptedPrivateIdObjectData = encryptedPrivateIdObjectData
        self.identityProviderEntity = identityProvider
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension IdentityCreationEntity: IdentityCreationDataType {
    var identityProvider: IdentityProviderDataType? {
        get {
            self.identityProviderEntity
        }
    }
}
