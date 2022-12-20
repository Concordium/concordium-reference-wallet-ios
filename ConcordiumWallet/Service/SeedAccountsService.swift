//
//  SeedAccountsService.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 10/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation
import Combine

protocol SeedAccountsServiceProtocol {
    func generateAccount(
        for identity: IdentityDataType,
        revealedAttributes: [String],
        requestPasswordDelegate: RequestPasswordDelegate
    ) async throws -> AccountDataType
    
    func recoverAccounts(
        for identities: [IdentityDataType],
        seed: Seed,
        pwHash: String
    ) async throws -> [AccountDataType]
}

struct SeedAccountsService {
    private let mobileWallet: SeedMobileWalletProtocol
    private let networkManager: NetworkManagerProtocol
    private let storageManager: StorageManagerProtocol
    private let keychainWrapper: KeychainWrapperProtocol
    
    init(
        mobileWallet: SeedMobileWalletProtocol,
        networkManager: NetworkManagerProtocol,
        storageManager: StorageManagerProtocol,
        keychainWrapper: KeychainWrapperProtocol
    ) {
        self.mobileWallet = mobileWallet
        self.networkManager = networkManager
        self.storageManager = storageManager
        self.keychainWrapper = keychainWrapper
    }
}

extension SeedAccountsService: SeedAccountsServiceProtocol {
    @MainActor func generateAccount(
        for identity: IdentityDataType,
        revealedAttributes: [String],
        requestPasswordDelegate: RequestPasswordDelegate
    )  async throws -> AccountDataType {
        let accountNumber = storageManager.getAccounts(for: identity).count
        let identityAttributes = revealedAttributes.reduce(into: [String: String]()) { partialResult, attribute in
            if let value = identity.identityObject?.attributeList.chosenAttributes[attribute] {
                partialResult[attribute] = value
            }
        }
        
        async let globalRequest = getGlobal()
        async let pwHashRequest = requestPasswordDelegate.requestUserPassword(keychain: keychainWrapper)
        
        let (global, pwHash) = try await (globalRequest, pwHashRequest)
        
        guard let seed = self.mobileWallet.getSeed(with: pwHash) else {
            throw GeneralError.unexpectedNullValue
        }
        
        let request = try await self.mobileWallet.createCredentialRequest(
            for: identity,
            global: global,
            revealedAttributes: revealedAttributes,
            accountNumber: accountNumber,
            seed: seed
        ).get()
        
        var account = try createAccount(
            at: accountNumber,
            createRequest: request,
            identity: identity,
            identityAttributes: identityAttributes,
            pwHash: pwHash
        )
        
        try await storeAccount(account)
        
        let submissionResponse = try await submitCredentialRequest(request)
        account = try await updateAccount(account, withSubmissionsId: submissionResponse.submissionID)
        
        let status = try await getSubmissionStatus(for: submissionResponse)
        account = try await updateAccount(account, withSubmissionStatus: status.status)
        
        return account
    }
    
    func recoverAccounts(
        for identities: [IdentityDataType],
        seed: Seed,
        pwHash: String
    ) async throws -> [AccountDataType] {
        let global = try await getGlobal()
        
        return await withTaskGroup(
            of: [AccountDataType].self
        ) { group in
            for identity in identities {
                group.addTask { await recoverAccounts(for: identity, global: global, seed: seed, pwHash: pwHash) }
            }
            
            var allAccounts = [AccountDataType]()
            for await accounts in group {
                allAccounts.append(contentsOf: accounts)
            }
            
            return allAccounts
        }
    }
    
    private func recoverAccounts(
        for identity: IdentityDataType,
        global: GlobalWrapper,
        seed: Seed,
        pwHash: String
    ) async -> [AccountDataType] {
        var accounts = [AccountDataType]()
        let allowedGap = 20
        var currentGap = 0
        var currentIndex = 0
        while currentGap < allowedGap {
            do {
                let request = try await self.mobileWallet.createCredentialRequest(
                    for: identity,
                    global: global,
                    revealedAttributes: [],
                    accountNumber: currentIndex,
                    seed: seed
                ).get()
                
                if let existingAccount = await getAccount(withAddress: request.accountAddress) {
                    accounts.append(existingAccount)
                    currentGap = 0
                } else {
                    let account = try createAccount(
                        at: currentIndex,
                        createRequest: request,
                        identity: identity,
                        identityAttributes: [:],
                        transactionStatus: .finalized,
                        pwHash: pwHash
                    )
                    
                    let accountBalance = try await getAccountBalance(for: account.address)
                    
                    if accountBalance.currentBalance != nil && accountBalance.finalizedBalance != nil {
                        try await storeAccount(account)
                        accounts.append(account)
                        
                        currentGap = 0
                    } else {
                        currentGap += 1
                    }
                }
            } catch {
                currentGap += 1
            }
            currentIndex += 1
        }
        
        return accounts
    }
    
    private func createAccount(
        at index: Int,
        createRequest request: CreateCredentialRequest,
        identity: IdentityDataType,
        identityAttributes: [String: String],
        transactionStatus: SubmissionStatusEnum? = nil,
        pwHash: String
    ) throws -> AccountDataType {
        var account = AccountDataTypeFactory.create()
        
        account.address = request.accountAddress
        account.accountIndex = index
        account.name = String(format: "recoveryphrase.account.name".localized, index)
        account.identity = identity
        account.revealedAttributes = identityAttributes
        account.encryptedBalanceStatus = .decrypted
        account.credential = request.credential
        account.transactionStatus = transactionStatus
        
        account.encryptedCommitmentsRandomness = try self.storageManager
            .storeCommitmentsRandomness(request.commitmentsRandomness, pwHash: pwHash).get()
        account.encryptedAccountData = try self.storageManager.storePrivateAccountKeys(request.accountKeys, pwHash: pwHash).get()
        account.encryptedPrivateKey = try self.storageManager.storePrivateEncryptionKey(request.encryptionSecretKey, pwHash: pwHash).get()
        
        return account
    }
    
    @MainActor
    private func storeAccount(_ account: AccountDataType) throws {
        _ = try storageManager.storeAccount(account)
        if account.transactionStatus == .finalized {
            let recipientEntity = RecipientEntity(name: account.displayName, address: account.address)
            try storageManager.storeRecipient(recipientEntity)
        }
    }
    
    @MainActor
    private func updateAccount(_ account: AccountDataType, withSubmissionsId submissionId: String) throws -> AccountDataType {
        try account.write {
            var mutableAccount = $0
            mutableAccount.submissionId = submissionId
        }.get()
        
        return account
    }
    
    @MainActor
    private func updateAccount(_ account: AccountDataType, withSubmissionStatus status: SubmissionStatusEnum) throws -> AccountDataType {
        try account.write {
            var mutableAccount = $0
            mutableAccount.transactionStatus = status
        }.get()
        
        if status == .finalized {
            let recipientEntity = RecipientEntity(name: account.displayName, address: account.address)
            try storageManager.storeRecipient(recipientEntity)
        }
        return account
    }
    
    @MainActor
    private func getAccount(withAddress address: String) -> AccountDataType? {
        storageManager.getAccount(withAddress: address)
    }
    
    private func submitCredentialRequest(
        _ request: CreateCredentialRequest
    ) async throws -> SubmissionResponse {
        let data = try request.credential.jsonData()
        
        return try await networkManager
            .load(
                ResourceRequest(url: ApiConstants.submitCredential, httpMethod: .put, body: data)
            )
    }
                
    private func getSubmissionStatus(
        for submissionResponse: SubmissionResponse
    ) async throws -> SubmissionStatus {
        
        return try await networkManager
            .load(
                ResourceRequest(url: ApiConstants.submissionStatus.appendingPathComponent(submissionResponse.submissionID))
            )
    }
    
    private func getAccountBalance(for address: String) async throws -> AccountBalance {
        try await networkManager.load(ResourceRequest(url: ApiConstants.accountBalance.appendingPathComponent(address)))
    }
    
    private func getGlobal() async throws -> GlobalWrapper {
        try await networkManager.load(.init(url: ApiConstants.global))
    }
}
