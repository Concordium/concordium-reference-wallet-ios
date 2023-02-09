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
    
    func createPendingIdentity(
        identityProvider: IdentityProviderDataType,
        pollURL: String,
        index: Int
    ) throws -> IdentityDataType {
        var newIdentity = IdentityDataTypeFactory.create()
        
        newIdentity.identityProvider = identityProvider
        newIdentity.nickname = identityName()
        newIdentity.state = .pending
        newIdentity.ipStatusUrl = pollURL
        newIdentity.accountsCreated = 0
        newIdentity.index = index
        try storageManager.storeIdentity(newIdentity)
        
        return newIdentity
    }
    
    var pendingIdentity: IdentityDataType? {
        storageManager.getIdentities()
            .first { identity in
                return identity.state == .pending || identity.accountsCreated == 0
            }
    }
    
    var confirmedIdentities: [IdentityDataType] {
        storageManager.getIdentities()
            .filter { $0.state == .confirmed }
    }
    
    func getIpInfo() async throws -> [IPInfoResponseElement] {
        try await networkManager.load(ResourceRequest(url: ApiConstants.ipInfoV1))
    }
    
    @MainActor
    func requestNextIdentity(
        from ipInfo: IPInfoResponseElement,
        requestPasswordDelegate: RequestPasswordDelegate
    ) async throws -> IDPIdentityRequest {
        let index = nextIdentityIndex(for: ipInfo)
        let identityProvider = IdentityProviderDataTypeFactory.create(ipData: ipInfo)
        
        let (id, request) = try await createSeedIdentityRequest(
            identityProvider: identityProvider,
            index: index,
            requestPasswordDelegate: requestPasswordDelegate
        )
        
        return .init(
            id: id,
            index: index,
            identityProvider: identityProvider,
            resourceRequest: request
        )
    }
    
    private func createSeedIdentityRequest(
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
    
    private func createSeedIdentityObjectRequest(on url: String, with seedIDRequest: SeedIDRequest) throws -> ResourceRequest {
        return try createIdentityObjectRequest(
            issuanceStartURL: url,
            idRequestString: try seedIDRequest.encodeToString(),
            redirectURI: seedIDRequest.redirectURI
        )
    }
    
    func recoverIdentities(
        with seed: Seed
    ) async throws -> ([[String: Any]], [String]) {
        async let globalRequeest = getGlobal()
        async let ipInfoRequest = getIpInfo()
        
        let (global, identityProviderInfo) = try await (globalRequeest, ipInfoRequest)
        var identityProviders = identityProviderInfo.map {
            IdentityProviderDataTypeFactory.create(ipData: $0)
        }
        identityProviders = identityProviders.filter { $0.ipInfo?.ipDescription.name != "instant_fail_provider" }
        
        var allidentities = [[String: Any]]()
        var failedIdentityProviders = [String]()
        let allowedGap = 20
        var currentGap = 0
        var currentIndex = 0
        while currentGap < allowedGap {
            var foundIdentity = false
            
            for identityProvider in identityProviders {
                let (identity, failedIdentityProvider) = await recoverIdentity(
                    atIndex: currentIndex,
                    generatedBy: seed,
                    global: global,
                    identityProvider: identityProvider
                )
                
                if identity != nil {
                    allidentities.append(identity!)
                    foundIdentity = true
                }
                if failedIdentityProvider != nil && !failedIdentityProviders.contains(failedIdentityProvider!) {
                    failedIdentityProviders.append(failedIdentityProvider!)
                }
            }
            
            if foundIdentity == true {
                currentGap = 0
            } else {
                currentGap += 1
            }
            
            currentIndex += 1
        }
        
        return (allidentities, failedIdentityProviders)
    }
    
    @MainActor
    private func recoverIdentity(
        atIndex index: Int,
        generatedBy seed: Seed,
        global: GlobalWrapper,
        identityProvider: IdentityProviderDataType
    ) async -> ([String: Any]?, String?) {
        
        guard
            var recoveryURL = identityProvider.recoverURL,
            let ipInfo = identityProvider.ipInfo
        else {
            return (nil, identityProvider.ipInfo?.ipDescription.name)
        }
        
        do {
            let request = try mobileWallet.createIDRecoveryRequest(
                for: ipInfo,
                global: global,
                index: index,
                seed: seed
            ).get()
            
            let recoverRequest = try request.encodeToString().addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)?.removingPercentEncoding
            
//            if recoveryURL.absoluteString == "https://id-service.testnet.concordium.com/api/v1/recover" {
//                recoveryURL = URL(string: "https://jashdjdshfjdhfdhjakfjhak.co")!
//            }
            
            let recoverResponse = try await networkManager.loadRecovery(ResourceRequest(url: recoveryURL, parameters: ["state" : recoverRequest]), decoding: SeedIdentityObjectWrapper.self)
            
            return try (createIdentityFromSeedIdentityObjectWrapper(
                recoverResponse,
                index: index,
                identityProvider: identityProvider
            ), nil)
        } catch NetworkError.dataLoadingError(let statusCode, let data) {
            if statusCode == 404 {
                var json: [String: Any]?
                
                do {
                    json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                } catch {}
                
                if json != nil {
                    return(nil, nil)
                } else {
                    return(nil, identityProvider.ipInfo?.ipDescription.name)
                }
            } else {
                return(nil, identityProvider.ipInfo?.ipDescription.name)
            }
        } catch {
            return (nil, identityProvider.ipInfo?.ipDescription.name)
        }
    }
    
    @MainActor
    private func createIdentityFromSeedIdentityObjectWrapper(
        _ seedIdentityObjectWrapper: SeedIdentityObjectWrapper,
        index: Int,
        identityProvider: IdentityProviderDataType
    ) throws -> [String: Any] {
        if let retrievedIdentity = storageManager.getIdentity(matchingSeedIdentityObject: seedIdentityObjectWrapper.value) {
            return ["identity": retrievedIdentity, "isNewlyCreated": false]
        }
        
        var identity = IdentityDataTypeFactory.create()
        identity.index = index
        identity.accountsCreated = 0
        identity.identityProvider = identityProvider
        identity.nickname = identityName()
        identity.state = .confirmed
        identity.seedIdentityObject = seedIdentityObjectWrapper.value
        
        try storageManager.storeIdentity(identity)
        
        return ["recover.identityKey".localized: identity, "recover.isNewlyCreatedKey".localized: true]
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
    
    @MainActor func updatePendingSeedIdentity(_ identity: IdentityDataType) async throws -> IdentityDataType {
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
    
    private func identityName() -> String {
        var counter = 1
        let identities = storageManager.getIdentities()
        
        while identities.contains(where: {$0.nickname == String(format: "recoveryphrase.identity.name".localized, counter)}) {
            counter += 1
        }

        return String(format: "recoveryphrase.identity.name".localized, counter)
    }
    
    private func nextIdentityIndex(for ipInfo: IPInfoResponseElement) -> Int {
        var maxIndex = 0
        
        for identity in storageManager.getIdentities() {
            if identity.identityProvider?.ipInfo?.ipIdentity == ipInfo.ipInfo.ipIdentity && identity.index > maxIndex {
                maxIndex = identity.index
            }
        }
        
        return maxIndex + 1
    }
}

private extension IdentityProviderDataType {
    var recoverURL: URL? {
        return recoveryStartURL.flatMap { URL(string: $0) }
    }
}
