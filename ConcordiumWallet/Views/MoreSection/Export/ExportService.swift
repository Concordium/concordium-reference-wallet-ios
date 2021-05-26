//
// Created by Johan Rugager Vase on 18/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation

enum ImportError: Error {
    case corruptDataError(reason: String)
    case unsupportedVersion(inputVersion: Int)
    case unsupportedWalletType(type: String)
    case unsupportedEnvironemt(environment: String)
}

struct ExportService {
    let storageManager: StorageManagerProtocol

    init(storageManager: StorageManagerProtocol) {
        self.storageManager = storageManager
    }

    func urlForFile() -> URL {
        let documentDirectory = FileManager.default.urls(for: .documentationDirectory, in: .userDomainMask).first!
        // it appears that the documentation directory does not necessarily exist in advance - create it if it doesn't
        try? FileManager.default.createDirectory(at: documentDirectory, withIntermediateDirectories: true)
        return documentDirectory.appendingPathComponent("export.concordiumwallet")
    }

    func deleteExportFile() throws {
        try FileManager.default.removeItem(at: urlForFile())
    }

    func export(pwHash: String, exportPassword: String) throws -> URL {
        let exportObject = exportAll(pwHash: pwHash)
        let exportObjectData = try exportObject.jsonData()

//        let json = try? exportObject.jsonString()
//        Logger.debug("json: \(json)")
        
        let exportDataWithEncryption = try encryptExport(exportObjectData, exportPassword: exportPassword)
        let url = urlForFile()
        Logger.trace("write export to file \(url)")
        try exportDataWithEncryption.write(to: url, options: .completeFileProtection)
        return url
    }

    private func encryptExport(_ exportObjectData: Data, exportPassword: String) throws -> Data {
        let iterations = 100_000
        let salt = AES256Crypter.randomSalt()
        let iv = AES256Crypter.randomIv()
        let encryptionMetadata = EncryptionMetadata(iterations: iterations,
                                                    salt: salt.base64EncodedString(),
                                                    initializationVector: iv.base64EncodedString())

        let key = try AES256Crypter.createKey(password: exportPassword, salt: salt, rounds: iterations)
        let cipher = try AES256Crypter(key: key, iv: iv).encrypt(exportObjectData)

        let exportContainer = ExportContainer(metadata: encryptionMetadata, cipherText: cipher.base64EncodedString())
        return try exportContainer.jsonData()
    }

    private func exportAll(pwHash: String) -> ExportVersionContainer {
        let recipients = getRecipients()
        let identities: [ExportIdentityData] = getIdentities(pwHash: pwHash)
        let exportContainer = ExportValues(identities: identities, recipients: recipients)
        return ExportVersionContainer(value: exportContainer)
    }

    private func getRecipients() -> [ExportRecipient] {
        //exclude unfinished accounts from recipients
        let unfinishedAccounts: [AccountDataType] = storageManager.getAccounts().filter { $0.transactionStatus != SubmissionStatusEnum.finalized }
        return storageManager.getRecipients().filter({ (recipient) -> Bool in
            !unfinishedAccounts.contains { (account) -> Bool in
                account.address == recipient.address
            }
        }).map { ExportRecipient(name: $0.name, address: $0.address) }
    }

    private func getIdentities(pwHash: String) -> [ExportIdentityData] {
        storageManager.getConfirmedIdentities().compactMap { identity in
            guard let privateIdObjectDataKey = identity.encryptedPrivateIdObjectData,
                  let privateIDObjectData = try? storageManager.getPrivateIdObjectData(key: privateIdObjectDataKey, pwHash: pwHash).get()
                    else { return nil }
            
            let accounts = getAccounts(for: identity, pwHash: pwHash)
            
            return ExportIdentityData(identity: identity,
                                      accounts: accounts,
                                      privateIdObjectData: privateIDObjectData)
        }
    }

    private func getAccounts(for identity: IdentityDataType, pwHash: String) -> [ExportAccount] {
        let accounts: [AccountDataType] = storageManager.getAccounts(for: identity).filter { $0.transactionStatus == SubmissionStatusEnum.finalized }
        let exportAccounts: [ExportAccount] = accounts.compactMap { account in
            guard let encryptedAccountDataKey = account.encryptedAccountData,
                  let accountKeys = try? storageManager.getPrivateAccountKeys(key: encryptedAccountDataKey, pwHash: pwHash).get()
                    else { return nil }
            
            guard let encryptionKeyKey = account.encryptedPrivateKey,
                let encryptionSecretKey = try? storageManager.getPrivateEncryptionKey(key: encryptionKeyKey, pwHash: pwHash).get() else { return nil }
            
            return ExportAccount(account: account, encryptedAccountKeys: accountKeys, encryptionSecretKey: encryptionSecretKey)
        }
        return exportAccounts
    }
    
    public func getUnfinalizedAccounts() -> [AccountDataType] {
        let accounts = storageManager.getAccounts().filter { (account) -> Bool in
            account.transactionStatus != SubmissionStatusEnum.finalized
        }
        return accounts
    }
    
}

extension ExportIdentityData {
    init?(identity: IdentityDataType, accounts: [ExportAccount], privateIdObjectData: PrivateIDObjectData?) {
        guard let identityProvider = identity.identityProvider,
              let ipInfo = identityProvider.ipInfo,
              let arsInfo = identityProvider.arsInfos,
              let identityObject = identity.identityObject,
              let privateIdObjectData = privateIdObjectData
                else { return nil }
        let ipMetaData = Metadata(issuanceStart: identityProvider.issuanceStartURL, icon: identityProvider.icon)
      
        let identityProviderElm = IPInfoResponseElement(ipInfo: ipInfo, arsInfos: arsInfo, metadata: ipMetaData)
        self.init(nextAccountNumber: identity.accountsCreated,
                  identityProvider: identityProviderElm,
                  identityObject: identityObject,
                  privateIdObjectData: privateIdObjectData,
                  name: identity.nickname,
                  accounts: accounts)
    }
}

extension ExportAccount {
    init?(account: AccountDataType, encryptedAccountKeys: AccountKeys, encryptionSecretKey: String) {
        guard let submissionId = account.submissionId,
            let credential = account.credential,
            let name = account.name else {
                return nil
        }

        self.init(name: name,
                  address: account.address,
                  submissionId: submissionId,
                  accountKeys: encryptedAccountKeys,
                  revealedAttributes: account.revealedAttributes,
                  credential: credential,
                  encryptionSecretKey: encryptionSecretKey)
    }
}
