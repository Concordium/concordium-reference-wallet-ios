//
// Created by Concordium on 04/05/2020.
// Copyright (c) 2020 concordium. All rights reserved.
//

import Foundation
import Combine
import RealmSwift
@testable import Mock

class StorageManagerMockHelper: StorageManagerProtocol {
    func storeCIS2Tokens(_ tokens: [Mock.CIS2TokenSelectionRepresentable], accountAddress: String, contractIndex: String) throws {
        NYI()
    }
    
    func getUserStoredCIS2Tokens(for accountAddress: String, in contractIndex: String) -> [Mock.CIS2TokenOwnershipEntity] {
        NYI()
    }
    
    func getCIS2Tokens(accountAddress: String) -> [Mock.CIS2TokenOwnershipEntity] {
        NYI()
    }
    
    func getCIS2TokenMetadataDetails(url: String) -> Mock.CIS2TokenMetadataDetailsEntity? {
        NYI()
    }
    
    func storeCIS2TokenMetadataDetails(_ metadata: Mock.CIS2TokenMetadataDetails, for url: String) throws {
        NYI()
    }
    
    var cachedTokensPublisher: AnyPublisher<RealmSwift.Results<Mock.CIS2TokenOwnershipEntity>, Error> = AnyPublisher<RealmSwift.Results<Mock.CIS2TokenOwnershipEntity>, Error>.fail(NetworkError.invalidRequest)

    func getLastAcceptedTermsAndConditionsVersion() -> String {
        NYI()
    }

    func storeLastAcceptedTermsAndConditionsVersion(_ version: String) {
        NYI()
    }

    func getIdentity(matchingSeedIdentityObject seedIdentityObject: SeedIdentityObject) -> IdentityDataType? {
        NYI()
    }

    func storeIdentity(_: IdentityDataType) throws {
        NYI()
    }

    func getIdentities() -> [IdentityDataType] {
        NYI()
    }

    func getIdentity(matchingIdentityObject identityObject: IdentityObject) -> IdentityDataType? {
        NYI()
    }

    func getConfirmedIdentities() -> [IdentityDataType] {
        NYI()
    }

    func getPendingIdentities() -> [IdentityDataType] {
        NYI()
    }

    func removeIdentity(_ identity: IdentityDataType?) {
        NYI()
    }

    func storePrivateIdObjectData(_: PrivateIDObjectData, pwHash: String) -> Result<String, Error> {
        NYI()
    }

    func getPrivateIdObjectData(key: String, pwHash: String) -> Result<PrivateIDObjectData, KeychainError> {
        NYI()
    }

    func removePrivateIdObjectData(key: String) {
        NYI()
    }

    func storePrivateAccountKeys(_ privateAccountKeys: AccountKeys, pwHash: String) -> Result<String, Error> {
        NYI()
    }

    func getPrivateAccountKeys(key: String, pwHash: String) -> Result<AccountKeys, Error> {
        NYI()
    }

    func removePrivateAccountKeys(key: String) {
        NYI()
    }

    func updatePrivateAccountDataPasscode(for account: AccountDataType, accountData: AccountKeys, pwHash: String) -> Result<Void, Error> {
        NYI()
    }

    func storePrivateEncryptionKey(_ privateKey: String, pwHash: String) -> Result<String, Error> {
        NYI()
    }

    func getPrivateEncryptionKey(key: String, pwHash: String) -> Result<String, Error> {
        NYI()
    }

    func removePrivateEncryptionKey(key: String) {
        NYI()
    }

    func updatePrivateEncryptionKeyPasscode(for account: AccountDataType, privateKey: String, pwHash: String) -> Result<Void, Error> {
        NYI()
    }

    func storeCommitmentsRandomness(_ commitmentsRandomness: CommitmentsRandomness, pwHash: String) -> Result<String, Error> {
        NYI()
    }

    func getCommitmentsRandomness(key: String, pwHash: String) -> Result<CommitmentsRandomness, Error> {
        NYI()
    }

    func updateCommitmentsRandomnessPasscode(
        for account: AccountDataType,
        commitmentsRandomness: CommitmentsRandomness,
        pwHash: String
    ) -> Result<Void, Error> {
        NYI()
    }

    func getNextAccountNumber(for identity: IdentityDataType) -> Result<Int, StorageError> {
        NYI()
    }

    func storeAccount(_ account: AccountDataType) throws -> AccountDataType {
        NYI()
    }

    func getAccounts() -> [AccountDataType] {
        NYI()
    }

    func getAccounts(for identity: IdentityDataType) -> [AccountDataType] {
        NYI()
    }

    func getAccount(withAddress: String) -> AccountDataType? {
        NYI()
    }

    func removeAccount(account: AccountDataType?) {
        NYI()
    }

    func storeShieldedAmount(amount: ShieldedAmountType) throws -> ShieldedAmountType {
        NYI()
    }

    func getShieldedAmountsForAccount(_ account: AccountDataType) -> [ShieldedAmountType] {
        NYI()
    }

    func getShieldedAmount(encryptedValue: String, account: AccountDataType) -> ShieldedAmountType? {
        NYI()
    }

    func storeRecipient(_ recipient: RecipientDataType) throws -> RecipientDataType {
        NYI()
    }

    func editRecipient(oldRecipient: RecipientDataType, newRecipient: RecipientDataType) throws {
        NYI()
    }

    func getRecipients() -> [RecipientDataType] {
        NYI()
    }

    func getRecipient(withAddress address: String) -> RecipientDataType? {
        NYI()
    }

    func getRecipient(withName: String, address: String) -> RecipientDataType? {
        NYI()
    }

    func removeRecipient(_ recipient: RecipientDataType?) {
        NYI()
    }

    func storeTransfer(_ transfer: TransferDataType) throws -> TransferDataType {
        NYI()
    }

    func getTransfers(for accountAddress: String) -> [TransferDataType] {
        NYI()
    }

    func getLastEncryptedBalanceTransfer(for accountAddress: String) -> TransferDataType? {
        NYI()
    }

    func getAllTransfers() -> [TransferDataType] {
        NYI()
    }

    func removeTransfer(_ transfer: TransferDataType?) {
        NYI()
    }

    func removeUnfinishedIdentities() {
        NYI()
    }

    func removeUnfinishedAccounts() {
        NYI()
    }

    func removeAccountsWithoutAddress() {
        NYI()
    }

    func removeUnfinishedAccountsAndRelatedIdentities() {
        NYI()
    }

    func getPendingAccountsAddresses() -> [String] {
        NYI()
    }

    func storePendingAccount(with address: String) {
        NYI()
    }

    func removePendingAccount(with address: String) {
        NYI()
    }

    func updateChainParms(_ chainParams: ChainParametersDataType) throws -> ChainParametersDataType {
        NYI()
    }

    func getChainParams() -> ChainParametersEntity? {
        NYI()
    }
}
