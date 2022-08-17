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
    func generateAccount(
        for identity: IdentityDataType,
        revealedAttributes: [String],
        requestPasswordDelegate: RequestPasswordDelegate
    )  async throws -> AccountDataType {
        let accountNumber = identity.accountsCreated
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
        
        var account = AccountDataTypeFactory.create()
        
        account.address = request.accountAddress
        account.accountIndex = accountNumber
        account.name = String(format: "recoveryphrase.account.name".localized, accountNumber)
        account.identity = identity
        account.revealedAttributes = identityAttributes
        account.encryptedBalanceStatus = .decrypted
        account.credential = request.credential
        
        account.encryptedCommitmentsRandomness = try self.storageManager
            .storeCommitmentsRandomness(request.commitmentsRandomness, pwHash: pwHash).get()
        account.encryptedAccountData = try self.storageManager.storePrivateAccountKeys(request.accountKeys, pwHash: pwHash).get()
        account.encryptedPrivateKey = try self.storageManager.storePrivateEncryptionKey(request.encryptionSecretKey, pwHash: pwHash).get()
        
        try await storeAccount(account)
        
        let submissionResponse = try await submitCredentialRequest(request)
        account = try await updateAccount(account, withSubmissionsId: submissionResponse.submissionID)
        
        let status = try await getSubmissionStatus(for: submissionResponse)
        account = try await updateAccount(account, withSubmissionStatus: status.status)
        
        return account
    }
    
    @MainActor
    private func storeAccount(_ account: AccountDataType) throws {
        _ = try storageManager.storeAccount(account)
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
        
        return account
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
    
    private func getGlobal() async throws -> GlobalWrapper {
        try await networkManager.load(.init(url: ApiConstants.global))
    }
}
