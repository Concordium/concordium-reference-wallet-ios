//
// Created by Concordium on 04/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
@testable import ProdMainNet

class StorageManagerMockHelper: StorageManagerProtocol {
    func storeIdentity(_ type: IdentityDataType) throws {
    }

    func getConfirmedIdentities() -> [IdentityDataType] {
        fatalError("getConfirmedIdentities() has not been implemented")
    }

    func getPendingIdentities() -> [IdentityDataType] {
        fatalError("getPendingIdentities() has not been implemented")
    }

    func removeIdentity(_ identity: IdentityDataType?) {
    }

    func getAccounts(for identity: IdentityDataType) -> [AccountDataType] {
        fatalError("getAccounts(for:) has not been implemented")
    }
    
    func editRecipient(oldRecipient: RecipientDataType, newRecipient: RecipientDataType) throws {
    }
    
    func removeRecipient(_ recipient: RecipientDataType?) {
    }
    
    func getIdentities() -> [IdentityDataType] {
        fatalError("getIdentities() has not been implemented")
    }

    func storePrivateIdObjectData(_ data: PrivateIDObjectData, pwHash: String) -> Result<String, Error> {
        fatalError("storePrivateIdObjectData(_:pwHash:) has not been implemented")
    }

    func getPrivateIdObjectData(key: String, pwHash: String) -> Result<PrivateIDObjectData, KeychainError> {
        fatalError("getPrivateIdObjectData(key:pwHash:) has not been implemented")
    }

    func storePrivateAccountData(_ privateAccountData: AccountKeys, pwHash: String) -> Result<String, Error> {
        fatalError("storePrivateAccountData(_:pwHash:) has not been implemented")
    }

    func getPrivateAccountData(key: String, pwHash: String) -> Result<AccountData, Error> {
        fatalError("getPrivateAccountData(key:pwHash:) has not been implemented")
    }

    func getNextAccountNumber(for identity: IdentityDataType) -> Result<Int, StorageError> {
        fatalError("getNextAccountNumber(for:) has not been implemented")
    }

    func storeAccount(_ account: AccountDataType) throws -> AccountDataType {
        fatalError("storeAccount(_:) has not been implemented")
    }

    func storeRecipient(_ recipient: RecipientDataType) throws -> RecipientDataType {
        fatalError("storeRecipient(_:) has not been implemented")
    }

    func storeTransfer(_ transfer: TransferDataType) throws -> TransferDataType {
        fatalError("storeTransfer(_:) has not been implemented")
    }

    func getAccounts() -> [AccountDataType] {
        fatalError("getAccounts() has not been implemented")
    }

    func getTransfers(for accountAddress: String) -> [TransferDataType] {
        fatalError("getTransfers(for:) has not been implemented")
    }

    func getAllTransfers() -> [TransferDataType] {
        fatalError("getAllTransfers() has not been implemented")
    }

    func getRecipients() -> [RecipientDataType] {
        fatalError("getRecipients() has not been implemented")
    }

    func getRecipient(withAddress address: String) -> RecipientDataType? {
        fatalError("getRecipient(withAddress:) has not been implemented")
    }

    func removeAccount(account: AccountDataType?) {
    }

    func removeTransfer(_ transfer: TransferDataType?) {
    }
}
