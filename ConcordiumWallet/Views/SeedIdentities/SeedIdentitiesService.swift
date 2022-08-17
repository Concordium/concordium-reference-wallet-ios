//
//  SeedIdentitiesService.swift
//  ConcordiumWallet
//
//  Created by Niels Christian Friis Jakobsen on 12/08/2022.
//  Copyright © 2022 concordium. All rights reserved.
//

import Foundation

struct SeedIdentitiesService {
    private let networkManager: NetworkManagerProtocol
    private let storageManager: StorageManagerProtocol
    private let mobileWallet: SeedMobileWalletProtocol
    
    init(
        networkManager: NetworkManagerProtocol,
        storageManager: StorageManagerProtocol,
        mobileWallet: SeedMobileWalletProtocol
    ) {
        self.networkManager = networkManager
        self.storageManager = storageManager
        self.mobileWallet = mobileWallet
    }
    
    func getNextIdentityIndex(for identityProvider: IdentityProviderDataType) -> Int {
        storageManager.getIdentities()
            .filter { $0.identityProvider?.ipInfo?.ipIdentity == identityProvider.ipInfo?.ipIdentity }
            .count
    }
    
    var pendingIdentity: IdentityDataType? {
        storageManager.getIdentities()
            .first { identity in
                return identity.state == .pending || identity.accountsCreated == 0
            }
    }
    
    func getIpInfo() async throws -> [IPInfoResponseElement] {
        try await networkManager.load(ResourceRequest(url: ApiConstants.ipInfo))
    }
    
    func createPendingIdentity(
        identityProvider: IdentityProviderDataType,
        pollURL: String,
        index: Int
    ) throws -> IdentityDataType {
        var newIdentity = IdentityDataTypeFactory.create()
        
        newIdentity.identityProvider = identityProvider
        newIdentity.nickname = String(format: "recoveryphrase.identity.name".localized, index)
        newIdentity.state = .pending
        newIdentity.ipStatusUrl = pollURL
        newIdentity.accountsCreated = 0
        newIdentity.index = index
        try storageManager.storeIdentity(newIdentity)
        
        return newIdentity
    }
    
    func createSeedIdentityRequest(
        identityProvider: IdentityProviderDataType,
        index: Int,
        requestPasswordDelegate: RequestPasswordDelegate
    ) async throws -> (String, ResourceRequest) {
        async let seedRequest = mobileWallet.getSeed(withDelegate: requestPasswordDelegate)
        async let globalRequest = getGlobal()
        
        let idRequest = try await mobileWallet.createIDRequest(
            for: identityProvider,
            index: index,
            globalValues: try await globalRequest,
            seed: try await seedRequest
        ).get()
        
        let requestID = UUID().uuidString
        return (requestID, try createSeedIdentityObjectRequest(
            on: identityProvider.issuanceStartURL,
            with: .init(
                idObjectRequest: idRequest.idObjectRequest,
                redirectURI: ApiConstants.callbackUri(
                    with: requestID
                )
            )
        ))
    }
    
    func createSeedIdentityObjectRequest(on url: String, with seedIDRequest: SeedIDRequest) throws -> ResourceRequest {
        return try createIdentityObjectRequest(
            issuanceStartURL: url,
            idRequestString: try seedIDRequest.encodeToString(),
            redirectURI: seedIDRequest.redirectURI
        )
    }
    
    private func createIdentityObjectRequest(
        issuanceStartURL: String,
        idRequestString: String,
        redirectURI: String
    ) throws -> ResourceRequest {
        guard let startURL = URL(string: issuanceStartURL),
              let urlWithoutParams = startURL.urlWithoutParameters
        else {
            throw GeneralError.unexpectedNullValue
        }
        
        let originalParameters = startURL.queryParameters
        
        var parameters: [String: String] = [
            "response_type": "code",
            "redirect_uri": redirectURI,
            "scope": "identity",
            "state": idRequestString
        ]
        
        if let originalParameters = originalParameters {
            parameters = parameters.merging(originalParameters) { $1 }
        }
        
        return ResourceRequest(url: urlWithoutParams, parameters: parameters)
    }
    
    func updatePendingSeedIdentity(_ identity: IdentityDataType) async throws -> IdentityDataType {
        guard identity.state == .pending else {
            return identity
        }
        
        guard let url = URL(string: identity.ipStatusUrl) else {
            return await updateIdentity(identity, withCreationError: "identityCreation.dataCorrupted".localized)
        }
        
        let status = try await networkManager.load(.init(url: url), decoding: SeedIdentityCreationStatus.self)
        
        switch status {
        case .pending:
            return identity
        case .done(let identityWrapperShell):
            return await updateIdentity(identity, withIdentityObject: identityWrapperShell.identityObject.value)
        case .error(let detail):
            return await updateIdentity(identity, withCreationError: detail)
        }
    }
    
    @MainActor
    private func updateIdentity(_ identity: IdentityDataType, withIdentityObject identityObject: SeedIdentityObject) -> IdentityDataType {
        return identity.withUpdated(seedIdentityObject: identityObject)
    }
    
    @MainActor
    private func updateIdentity(_ identity: IdentityDataType, withCreationError error: String) -> IdentityDataType {
        return identity.withUpdated(identityCreationError: error)
    }
    
    private func getGlobal() async throws -> GlobalWrapper {
        return try await networkManager.load(ResourceRequest(url: ApiConstants.global))
    }
}
