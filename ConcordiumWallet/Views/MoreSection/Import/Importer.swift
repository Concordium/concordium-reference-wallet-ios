//
// Created by Concordium on 12/09/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import Combine

struct ImportedIdentity {
    var name: String
    var importedAccounts: [String] = []
    var readOnlyAccounts: [String] = []
    var duplicateAccounts: [String] = []
    var failedAccounts: [String] = []
}
struct ImportedItemsReport {
    var importedIdentities: [ImportedIdentity] = []
    var duplicateIdentities: [ImportedIdentity] = []
    var failedIdentities: [String] = []
    var importedRecipients: [String] = []
    var duplicateRecipients: [String] = []
    var failedRecipients: [String] = []
}

class Importer {
    private var importReport = ImportedItemsReport()
    let storageManager: StorageManagerProtocol
    let mobileWallet: MobileWalletProtocol
    let accountsService: AccountsServiceProtocol
    
    init(storageManager: StorageManagerProtocol, mobileWallet: MobileWalletProtocol, accountsService: AccountsServiceProtocol) {
        self.storageManager = storageManager
        self.mobileWallet = mobileWallet
        self.accountsService = accountsService
    }

    func importToDatabase(_ importData: ExportValues, pwHash: String) -> AnyPublisher<ImportedItemsReport, Error> {
        
        importData.recipients.forEach {
            importRecipient($0)
        }
        do {
            let publishers = try importData.identities.map { (importIdentityData) -> AnyPublisher<IdentityDataType?, Error> in
                                
                let accounts = try generateAccounts(identity: importIdentityData, pwHash: pwHash)
                let mappedImportedAccounts = accounts.map { (accounts) -> AnyPublisher<IdentityDataType?, Error> in
                    self.verifyAccounts(accounts: accounts).map { (accountElements) in
                        self.importIdentity(importIdentityData: importIdentityData,
                                            readOnlyAccounts: accountElements,
                                            pwHash: pwHash) }.eraseToAnyPublisher()
                }.flatMap { $0 }.eraseToAnyPublisher()
                return mappedImportedAccounts
            }
            let combinedPublishers = Publishers.Sequence(sequence: publishers)
                .flatMap { $0 }
                .collect()
                .eraseToAnyPublisher()
            // after all publishers are done we return the import report
            return combinedPublishers.map { _ in self.importReport  }.eraseToAnyPublisher()
        } catch {
            return .fail(error)
        }
    }
    
    private func generateAccounts(identity: ExportIdentityData, pwHash: String) throws -> AnyPublisher<[MakeGenerateAccountsResponseElement], Error>  {
        return accountsService.getGlobal()
            .flatMap { global -> AnyPublisher<[MakeGenerateAccountsResponseElement], Error>   in
                do {
                    let result =  try self.mobileWallet.getAccountAddressesForIdentity(global: global,
                                                                                       identityObject: identity.identityObject,
                                                                                       privateIDObjectData: identity.privateIdObjectData,
                                                                                       startingFrom: 0,
                                                                                       pwHash: pwHash)
                    let accounts = try result.get()
                    let filteredAccounts = accounts.filter { (account) -> Bool in
                        !identity.accounts.contains { (identityAccount) -> Bool in
                            identityAccount.address == account.accountAddress
                        }
                    }
                    return .just(filteredAccounts)
                } catch {
                    return .fail(error)
                }}.eraseToAnyPublisher()
    }
    
    private func verifyAccounts(accounts: [MakeGenerateAccountsResponseElement]) -> AnyPublisher<[MakeGenerateAccountsResponseElement], Error> {
        // filter accounts included in the import (we only include addresses that are now saved or are readonly
        let accountsToVerify = accounts.filter { (account) -> Bool in
            let storredAccount = storageManager.getAccount(withAddress: account.accountAddress)
            if storredAccount == nil || storredAccount?.isReadOnly == true {
                return true
            }
            return false
        }
        
        return accountsService.checkAccountExistance(accounts: accountsToVerify.map { $0.accountAddress } ).map { (accountsToImport) -> [MakeGenerateAccountsResponseElement] in
            accountsToVerify.filter { accountsToImport.contains($0.accountAddress) }
        }.eraseToAnyPublisher()
    }

    private func importIdentity(importIdentityData: ExportIdentityData, readOnlyAccounts: [MakeGenerateAccountsResponseElement], pwHash: String) -> IdentityDataType? {
        for acc in readOnlyAccounts {
            let address = acc.accountAddress
            let name = String(acc.accountAddress.prefix(8))
            importRecipient(ExportRecipient(name: name, address: address))
        }
        
        let identityImporter = IdentityImporter(identity: importIdentityData, storageManager: storageManager)
        return identityImporter.importIdentity(importIdentityData, readOnlyAccounts: readOnlyAccounts, pwHash: pwHash, importReport: &importReport)
    }

    private func importRecipient(_ recipientData: ExportRecipient) {
        guard storageManager.getRecipient(withName: recipientData.name, address: recipientData.address) == nil else {
            importReport.duplicateRecipients.append(recipientData.name)
            return
        }
        do {
            let recipient = RecipientEntity()
            recipient.name = recipientData.name
            recipient.address = recipientData.address
            try storageManager.storeRecipient(recipient)
            importReport.importedRecipients.append(recipientData.name)
        } catch {
            importReport.failedRecipients.append(recipientData.name)
        }
    }
}
