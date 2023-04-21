//
// Created by Concordium on 12/09/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation

class IdentityImporter {
    private var importedIdentity: ImportedIdentity
    let storageManager: StorageManagerProtocol

    init(identity: ExportIdentityData, storageManager: StorageManagerProtocol) {
        importedIdentity = ImportedIdentity(name: identity.name)
        self.storageManager = storageManager
    }

    func importIdentity(_ identityDataToImport: ExportIdentityData,
                        readOnlyAccounts: [MakeGenerateAccountsResponseElement],
                        pwHash: String,
                        importReport: inout ImportedItemsReport) -> IdentityDataType? {
        do {
            if let existingEntity = storageManager.getIdentity(matchingIdentityObject: identityDataToImport.identityObject) {
                // Here we have an identity stored.
                // We check whether the identity has its keys and if it does, we try to
                // import its accounts and mark it as duplicate in the report
               
                if let key = existingEntity.encryptedPrivateIdObjectData,
                   (try? storageManager.getPrivateIdObjectData(key: key, pwHash: pwHash).get()) != nil {
                    importAccounts(identityData: identityDataToImport, identityEntity: existingEntity, pwHash: pwHash)
                    importReadOnlyAccounts(readOnlyAccounts, identityEntity: existingEntity, pwHash: pwHash)
                    importReport.duplicateIdentities.append(importedIdentity)
                    return existingEntity
                } else {
                    // we delete the stored unusable identity
                    storageManager.removeIdentity(existingEntity)
                }
            }
            // if we are here, we need to import the identity, either because there is no
            // local copy or the local copy didn't contain keys
            let identityEntity = try storeIdentityInDb(identityDataToImport, pwHash: pwHash)
            importAccounts(identityData: identityDataToImport, identityEntity: identityEntity, pwHash: pwHash)
            importReadOnlyAccounts(readOnlyAccounts, identityEntity: identityEntity, pwHash: pwHash)
            importReport.importedIdentities.append(importedIdentity)
            return identityEntity
            
        } catch {
            importReport.failedIdentities.append(importedIdentity.name)
        }
        return nil
    }

    private func importAccounts(identityData: ExportIdentityData, identityEntity: IdentityDataType, pwHash: String) {
        identityData.accounts.forEach {
            importAccount($0, relatedIdentity: identityEntity, pwHash: pwHash)
        }
    }
    
    private func importReadOnlyAccounts(_ accounts: [MakeGenerateAccountsResponseElement], identityEntity: IdentityDataType, pwHash: String) {
        accounts.forEach {
            importReadOnlyAccount($0, relatedIdentity: identityEntity, pwHash: pwHash)
        }
    }

    private func storeIdentityInDb(_ identityData: ExportIdentityData, pwHash: String) throws -> IdentityDataType {
        let identity = IdentityEntity()
        identity.encryptedPrivateIdObjectData = try storageManager.storePrivateIdObjectData(identityData.privateIdObjectData, pwHash: pwHash).get()
        identity.accountsCreated = identityData.nextAccountNumber
        identity.identityProvider = IdentityProviderEntity(ipData: identityData.identityProvider)
        identity.identityObject = identityData.identityObject
        identity.nickname = identityData.name
        identity.state = .confirmed
        try storageManager.storeIdentity(identity)
        return identity
    }

    private func importAccount(_ accountData: ExportAccount, relatedIdentity: IdentityDataType, pwHash: String) {
        let existingAccount = storageManager.getAccount(withAddress: accountData.address)
        let accountContainsKeys: Bool
        if let storedAccount = existingAccount,
            let key = storedAccount.encryptedPrivateKey,
           (try? storageManager.getPrivateIdObjectData(key: key, pwHash: pwHash).get()) != nil {
            // if the privateIdObject is NOT nil, it means the account contains keys
            accountContainsKeys = true
        } else {
            accountContainsKeys = false
        }
        
        // we allow overwriting if the account is readonly or it doesn't contain keys
        guard existingAccount?.isReadOnly == true || !accountContainsKeys else {
            importedIdentity.duplicateAccounts.append(accountData.name)
            return
        }
        
        // we remove the readonly account if it exists
        // (we ony get here if we have a readonly account or
        // existing account is nil or doesn't contain keys)
        storageManager.removeAccount(account: existingAccount)
        
        do {
            let account = AccountEntity()
            account.name = accountData.name
            account.submissionId = accountData.submissionId
            account.transactionStatus = .finalized
            account.identity = relatedIdentity
            account.encryptedAccountData = try storageManager.storePrivateAccountKeys(accountData.accountKeys, pwHash: pwHash).get()
            account.address = accountData.address
            account.credential = accountData.credential
            if account.credential?.value.credential.type == "initial" {
                account.transactionStatus = .finalized
            }
            account.revealedAttributes = accountData.revealedAttributes
            
            if let commitmentsRandomness = accountData.commitmentsRandomness {
                account.encryptedCommitmentsRandomness = try storageManager.storeCommitmentsRandomness(commitmentsRandomness, pwHash: pwHash).get()
            }
            
            account.encryptedPrivateKey = try storageManager.storePrivateEncryptionKey(accountData.encryptionSecretKey, pwHash: pwHash).get()
            _ = try storageManager.storeAccount(account)
            importedIdentity.importedAccounts.append(accountData.name)
        } catch {
            importedIdentity.failedAccounts.append(accountData.name)
        }
    }
    
    private func importReadOnlyAccount(_ readOnlyAccount: MakeGenerateAccountsResponseElement, relatedIdentity: IdentityDataType, pwHash: String) {
        let existingAccount = storageManager.getAccount(withAddress: readOnlyAccount.accountAddress)
        guard existingAccount == nil else {
            // we don't import a read-only account if the account is already saved locally
            return
        }
        do {
            let account = AccountEntity()
            account.transactionStatus = .finalized
            account.identity = relatedIdentity
            account.address = readOnlyAccount.accountAddress
            account.credential = nil
            account.revealedAttributes = [:]
            account.isReadOnly = true
            account.encryptedPrivateKey = try storageManager.storePrivateEncryptionKey(readOnlyAccount.encryptionSecretKey, pwHash: pwHash).get()
            _ = try storageManager.storeAccount(account)
            importedIdentity.readOnlyAccounts.append(account.displayName)
        } catch {
            let address = readOnlyAccount.accountAddress
            let lowerBound = address.startIndex
            let upperBound = address.index(lowerBound, offsetBy: 8)
            importedIdentity.failedAccounts.append("<" + String(address[lowerBound..<upperBound]) + ">")
        }
    }
}
