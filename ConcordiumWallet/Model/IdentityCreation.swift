//
//  IdentityCreation.swift
//  ConcordiumWallet
//
//  Created by Concordium on 30/09/2021.
//  Copyright © 2021 concordium. All rights reserved.
//

import Foundation

final class IdentityCreation {
    /// Identifier used in the callback to identify this identity creation
    let id = UUID().uuidString
    /// Name of the initial account
    let initialAccountName: String
    /// Address of the initial account
    let initialAccountAddress: String
    /// Name of the identity
    let identityName: String
    /// Key for the stored account data object
    let encryptedAccountData: String
    /// Key for the stored private key
    let encryptedPrivateKey: String
    /// Key for the stored private ID object data
    let encryptedPrivateIdObjectData: String
    /// The identity provider used in creating the identity
    let identityProvider: IdentityProviderDataType
    
    private let storageManager: StorageManagerProtocol
    
    init (initialAccountName: String,
          initialAccountAddress: String,
          identityName: String,
          encryptedAccountData: String,
          encryptedPrivateKey: String,
          encryptedPrivateIdObjectData: String,
          identityProvider: IdentityProviderDataType,
          storageManager: StorageManagerProtocol) {
        self.initialAccountName = initialAccountName
        self.initialAccountAddress = initialAccountAddress
        self.identityName = identityName
        self.encryptedAccountData = encryptedAccountData
        self.encryptedPrivateKey = encryptedPrivateKey
        self.encryptedPrivateIdObjectData = encryptedPrivateIdObjectData
        self.identityProvider = identityProvider
        self.storageManager = storageManager
    }
    convenience init (initialAccountName: String,
                      identityName: String,
                      identityProvider: IdentityProviderDataType,
                      data: IDRequestAndPrivateData,
                      pwHash: String,
                      storageManager: StorageManagerProtocol) throws {
        let encryptedAccountData = try storageManager.storePrivateAccountKeys(data.initialAccountData.accountKeys,
                                                                              pwHash: pwHash).get()
        let encryptedPrivateKey = try storageManager.storePrivateEncryptionKey(data.initialAccountData.encryptionSecretKey,
                                                                               pwHash: pwHash).get()
        let encryptedPrivateIdObjectData =
            try storageManager.storePrivateIdObjectData(data.privateIDObjectData.value, pwHash: pwHash).get()
        
        self.init(initialAccountName: initialAccountName,
                  initialAccountAddress: data.initialAccountData.accountAddress,
                  identityName: identityName,
                  encryptedAccountData: encryptedAccountData,
                  encryptedPrivateKey: encryptedPrivateKey,
                  encryptedPrivateIdObjectData: encryptedPrivateIdObjectData,
                  identityProvider: identityProvider,
                  storageManager: storageManager)

    }
    deinit {
        // Clean up the encrypted data from the keyring, but only if the associated account
        // and identity were not created.
        guard storageManager.getAccount(withAddress: self.initialAccountAddress) == nil else { return }
        let matchingIdentity = storageManager.getIdentities().first {
            $0.encryptedPrivateIdObjectData == self.encryptedPrivateIdObjectData
        }
        guard matchingIdentity == nil else { return }
        storageManager.removePrivateAccountKeys(key: encryptedAccountData)
        storageManager.removePrivateEncryptionKey(key: encryptedPrivateKey)
        storageManager.removePrivateIdObjectData(key: encryptedPrivateIdObjectData)
    }
}
