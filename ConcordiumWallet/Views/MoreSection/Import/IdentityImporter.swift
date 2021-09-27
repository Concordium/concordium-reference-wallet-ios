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
            if let existingEntity = storageManager.getIdentity(matching: identityDataToImport.identityObject) {
                importAccounts(identityData: identityDataToImport, identityEntity: existingEntity, pwHash: pwHash)
                importReadOnlyAccounts(readOnlyAccounts, identityEntity: existingEntity, pwHash: pwHash)
                importReport.duplicateIdentities.append(importedIdentity)
                return existingEntity
            } else {
                let identityEntity = try storeIdentityInDb(identityDataToImport, pwHash: pwHash)
                importAccounts(identityData: identityDataToImport, identityEntity: identityEntity, pwHash: pwHash)
                importReadOnlyAccounts(readOnlyAccounts, identityEntity: identityEntity, pwHash: pwHash)
                importReport.importedIdentities.append(importedIdentity)
                return identityEntity
            }
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
        
        // we allow overwritting
        guard existingAccount == nil || existingAccount?.isReadOnly == true else {
            importedIdentity.duplicateAccounts.append(accountData.name)
            return
        }
        // we remove the readonly account if it exists
        // (we ony get here if we have a readonly account or existing account is nil)
        storageManager.removeAccount(account: existingAccount)
        
        do {
            let account = AccountEntity()
            account.name = accountData.name
            account.submissionId = accountData.submissionId
            account.transactionStatus = .received
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
//            importedIdentity.duplicateAccounts.append(existingAccount?.name ?? "")
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
